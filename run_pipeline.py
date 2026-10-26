#!/usr/bin/env python3
"""Run the available Switch-TRIBE edit-identification stages from a manifest."""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
CODE = ROOT / "code"
__version__ = "0.1.0"
MYSQL_DATABASE = "dmseq"
MYSQL_HOST = "localhost"
MYSQL_USER = "root"
REQUIRED_COLUMNS = {
    "assay", "sample_id", "table_name", "experiment", "timepoint", "fastq", "sam"
}

# Final annotation and output names recorded by BRAT_new/ and MEIP26_new/.
# The cluster combinations themselves are kept in the shell script together
# with the historical seqkit/STAR commands.
CURRENT_SINGLE_CELL_SAMS = {
    "BRAT": {
        "BRAT_SC_DIM15_NB": "BRAT_dim15_NB_hq.sam",
        "BRAT_SC_DIM15_INP": "BRAT_dim15_INP_hq.sam",
        "BRAT_SC_DIM15_GMCT1": "BRAT_dim15_GMCTI_hq.sam",
        "BRAT_SC_DIM15_GMCT2": "BRAT_dim15_GMCTII_hq.sam",
        "BRAT_SC_DIM15_Neuron_T1T2": "BRAT_dim15_Neuron_T1T2_hq.sam",
        "BRAT_SC_DIM15_Neuron_else_1": "BRAT_dim15_Neuron_else_1_hq.sam",
        "BRAT_SC_DIM15_Neuron_else_2": "BRAT_dim15_Neuron_else_2_hq.sam",
        "BRAT_SC_DIM15_Glia_T1T2": "BRAT_dim15_Glia_T1T2_hq.sam",
        "BRAT_SC_DIM15_Glia_else": "BRAT_dim15_Glia_else_hq.sam",
    },
    "MEIP26": {
        "MEIP26_SC_NB": "MEIP26_NB_hq.sam",
        "MEIP26_SC_INP": "MEIP26_INP_hq.sam",
        "MEIP26_SC_GMCT1": "MEIP26_GMCT1_hq.sam",
        "MEIP26_SC_GMCT2": "MEIP26_GMCT2_hq.sam",
        "MEIP26_SC_Neuron_T1T2": "MEIP26_Neuron_T1T2_hq.sam",
        "MEIP26_SC_Neuron_else": "MEIP26_Neuron_else_hq.sam",
        "MEIP26_SC_Glia": "MEIP26_Glia_hq.sam",
    },
}


def read_config(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        config = json.load(handle)
    config["_config_dir"] = str(path.resolve().parent)
    return config


def resolve_path(value: str | None, config: dict) -> Path | None:
    if not value:
        return None
    path = Path(value).expanduser()
    if not path.is_absolute():
        path = Path(config["_config_dir"]) / path
    return path.resolve()


def run(command: list[str], *, cwd: Path | None = None, env: dict | None = None) -> None:
    print("+", shlex.join(command), flush=True)
    subprocess.run(command, cwd=cwd, env=env, check=True)


def ensure_database(config: dict) -> None:
    """Use HyperTRIBE's local dmseq/root/empty-password connection convention."""
    mysql = config.get("mysql", "mysql")
    run([mysql, f"--host={MYSQL_HOST}", f"--user={MYSQL_USER}",
         "--execute=CREATE DATABASE IF NOT EXISTS `dmseq`"])


def ensure_star_index(config: dict, outdir: Path) -> Path:
    fasta = resolve_path(config.get("genome_fasta"), config)
    if fasta is None or not fasta.is_file():
        raise FileNotFoundError("Set genome_fasta to the reference genome FASTA")
    gtf = resolve_path(config.get("genome_gtf"), config)
    if gtf is not None and not gtf.is_file():
        raise FileNotFoundError(f"STAR annotation GTF not found: {gtf}")
    index = outdir / "reference" / "STAR_index"
    if (index / "Genome").is_file() and (index / "SA").is_file():
        return index
    index.mkdir(parents=True, exist_ok=True)
    script = CODE / "bulk" / "build_star_index.sh"
    run(["bash", str(script), str(fasta), str(gtf) if gtf else "-", str(index),
         str(config.get("star_index_threads", 20)), str(config.get("sjdb_overhang", 149)),
         str(config.get("star", "STAR"))])
    if not (index / "Genome").is_file() or not (index / "SA").is_file():
        raise RuntimeError(f"STAR did not produce a complete index in {index}")
    return index


def existing_tables(config: dict) -> set[str]:
    mysql = config.get("mysql", "mysql")
    command = [mysql, f"--host={MYSQL_HOST}", f"--user={MYSQL_USER}", "--batch",
               "--skip-column-names", "--execute=SHOW TABLES", MYSQL_DATABASE]
    result = subprocess.run(command, check=True, text=True, capture_output=True)
    return set(result.stdout.splitlines())


def read_manifest(path: Path, assay: str) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        missing = REQUIRED_COLUMNS - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Manifest is missing columns: {', '.join(sorted(missing))}")
        rows = [row for row in reader if row.get("assay", "").strip() == assay]
    if not rows:
        raise ValueError(f"No manifest rows found for assay={assay!r}")
    names = [row["table_name"].strip() for row in rows]
    if len(names) != len(set(names)):
        if assay != "single_cell":
            raise ValueError(f"Duplicate table_name values for assay={assay!r}")
        # The template includes historical and current MEIP26 rows that share
        # a count-table name. Keep the last row, which records the current SAM.
        latest: dict[str, dict[str, str]] = {}
        for row in rows:
            latest[row["table_name"].strip()] = row
        rows = list(latest.values())
    return rows


def row_value(row: dict[str, str], key: str) -> str:
    value = row.get(key, "").strip()
    if not value or value.upper() == "NA" or value.startswith("REPLACE"):
        raise ValueError(f"Manifest value {key!r} is empty or a template placeholder")
    return value


def safe_sample_id(row: dict[str, str]) -> str:
    sample_id = row_value(row, "sample_id")
    if not re.fullmatch(r"[A-Za-z0-9_.-]+", sample_id):
        raise ValueError(f"Unsafe sample_id: {sample_id}")
    return sample_id


def prepare_bulk(rows: list[dict[str, str]], config: dict, outdir: Path) -> None:
    script = CODE / "bulk" / "preprocess_fastq_to_sam.sh"
    index = ensure_star_index(config, outdir)
    for row in rows:
        sample_id = safe_sample_id(row)
        fastq = resolve_path(row.get("fastq", ""), config)
        if fastq is None or not fastq.is_file():
            raise FileNotFoundError(f"Input FASTQ not found for {sample_id}: {fastq}")
        sample_dir = outdir / "bulk" / sample_id
        run(["bash", str(script), sample_id, str(fastq), str(index), str(sample_dir),
             str(config.get("trimmomatic", "trimmomatic")),
             str(config.get("picard", "picard")), config.get("star", "STAR"),
             config.get("samtools", "samtools"), str(config.get("bulk_threads", 8))])
        row["sam"] = str(sample_dir / f"{sample_id}_rmdup_sorted.sam")


def prepare_single_cell(rows: list[dict[str, str]], config: dict, outdir: Path) -> None:
    """Recover TRIBE read pairs from raw FASTQ, then create cell-type SAMs."""
    libraries = config.get("single_cell_inputs")
    if not isinstance(libraries, dict):
        raise ValueError("Set single_cell_inputs for BRAT and MEIP26 in the pipeline configuration")
    barcode_root = resolve_path(config.get("cell_type_barcodes", "resources/cell_type_barcodes"), config)
    if barcode_root is None or not barcode_root.is_dir():
        raise FileNotFoundError(f"cell_type_barcodes directory not found: {barcode_root}")
    index = ensure_star_index(config, outdir)
    celltype_script = CODE / "single_cell" / "preprocess_celltype_sam.sh"
    recovery_script = CODE / "single_cell" / "recover_tribe_reads.sh"
    table_rows = {row_value(row, "table_name"): row for row in rows}
    expected_tables = set().union(*(mapping.keys() for mapping in CURRENT_SINGLE_CELL_SAMS.values()))
    unexpected = sorted(set(table_rows) - expected_tables)
    if unexpected:
        raise ValueError("Single-cell manifest contains non-final table names: " + ", ".join(unexpected))
    missing = sorted(expected_tables - set(table_rows))
    if missing:
        raise ValueError("Single-cell manifest is missing final table names: " + ", ".join(missing))

    for assay, sam_names in CURRENT_SINGLE_CELL_SAMS.items():
        library = libraries.get(assay)
        if not isinstance(library, dict):
            raise ValueError(f"single_cell_inputs.{assay} is required")
        r1 = resolve_path(library.get("raw_r1_fastq"), config)
        r2 = resolve_path(library.get("raw_r2_fastq"), config)
        if r1 is None or not r1.is_file() or r2 is None or not r2.is_file():
            raise FileNotFoundError(f"Set existing raw_r1_fastq and raw_r2_fastq for single_cell_inputs.{assay}")
        assay_dir = outdir / "single_cell" / assay
        recovery_dir = assay_dir / "recovery"
        pattern_file = recovery_dir / "target_patterns.tab"
        recovery_dir.mkdir(parents=True, exist_ok=True)
        if assay == "BRAT":
            pattern_file.write_text("GCATAACTTCGTATAGCATACATTATACGAAGTTATCG\n", encoding="utf-8")
        else:
            refsite = outdir / "bulk" / "OUTPUT" / "MEIP26_TRIBE_BULK_ex4o_cor.bed"
            if not refsite.is_file():
                raise FileNotFoundError(
                    "MEIP26 target-pattern generation needs the pipeline-produced bulk BED: "
                    f"{refsite}. Run the bulk identify stage first."
                )
            annotation = resolve_path(config.get("gene_annotation_bed"), config)
            if annotation is None or not annotation.is_file():
                raise FileNotFoundError("Set gene_annotation_bed to generate MEIP26 target patterns")
            # niagara.bash generated these 25-nt patterns with the r6.54
            # annotation FASTA, not the r6.60 FASTA used to build STAR's
            # alignment index.
            fasta = resolve_path(config.get("annotation_fasta"), config)
            if fasta is None or not fasta.is_file():
                raise FileNotFoundError(
                    "Set annotation_fasta to dmel-all-chromosome-r6.54.fasta "
                    "for MEIP26 target-pattern generation"
                )
            run(["bash", str(CODE / "single_cell" / "build_meip26_target_patterns.sh"),
                 str(refsite), str(annotation), str(fasta), str(pattern_file),
                 config.get("bedtools", "bedtools"), str(recovery_dir / "reference_sites")])
        run(["bash", str(recovery_script), assay, str(r1), str(r2), str(recovery_dir),
             config.get("seqkit", "seqkit"), str(config.get("single_cell_threads", 20)),
             str(config.get("single_cell_split_parts", 20)), str(pattern_file)])
        if assay == "BRAT":
            tribe_r1 = recovery_dir / "BRAT_TRIBE_R1.fastq.gz"
            tribe_r2 = recovery_dir / "BRAT_TRIBE_R2.fastq.gz"
        else:
            tribe_r1 = recovery_dir / "MEIP26_TRIBE_ALL_R1.fastq"
            # The recovery job named this output inconsistently in one script,
            # but the final MEIP26_new pairing and STAR jobs consume the gzip
            # stream as MEIP26_TRIBE_ALL_R2.fastq.gz.
            tribe_r2 = recovery_dir / "MEIP26_TRIBE_ALL_R2.fastq.gz"
        run(["bash", str(celltype_script), assay, str(tribe_r1), str(tribe_r2), str(index), str(barcode_root),
             str(assay_dir), config.get("seqkit", "seqkit"), config.get("star", "STAR"),
             config.get("samtools", "samtools"), str(config.get("single_cell_threads", 20))])
        for table_name, sam_name in sam_names.items():
            table_rows[table_name]["sam"] = str(assay_dir / "sam" / sam_name)


def validate_sams(rows: list[dict[str, str]], config: dict) -> list[tuple[dict[str, str], Path]]:
    resolved = []
    for row in rows:
        sam = resolve_path(row.get("sam", ""), config)
        if sam is None or not sam.is_file():
            raise FileNotFoundError(f"SAM not found for {row.get('sample_id', '<unknown>')}: {sam}")
        resolved.append((row, sam))
    return resolved


def load_matrices(rows: list[dict[str, str]], config: dict, assay: str) -> None:
    hypertribe = resolve_path(config.get("hypertribe_code"), config)
    if hypertribe is None or not (hypertribe / "sam_to_matrix.pl").is_file():
        raise FileNotFoundError("hypertribe_code must point to a directory containing sam_to_matrix.pl")
    loader = CODE / "loaders" / "load_matrix_data_configurable.pl"
    perl = config.get("perl", "perl")
    env = os.environ.copy()

    collisions = sorted({row_value(row, "table_name") for row in rows} & existing_tables(config))
    if collisions:
        raise ValueError(
            "Count tables already exist; use a fresh schema or remove them through your database administrator: "
            + ", ".join(collisions[:10])
        )

    matrix_dir = resolve_path(config.get("output_dir", "output"), config) / assay / "matrix"
    matrix_dir.mkdir(parents=True, exist_ok=True)
    for row, source_sam in validate_sams(rows, config):
        sample_id = safe_sample_id(row)
        sam = matrix_dir / f"{sample_id}.sam"
        shutil.copy2(source_sam, sam)
        table = row_value(row, "table_name")
        experiment = row_value(row, "experiment")
        timepoint = row_value(row, "timepoint")
        matrix_wig = Path(str(sam) + ".matrix.wig")
        matrix = sam.with_suffix(".matrix")
        run([perl, str(hypertribe / "sam_to_matrix.pl"), str(sam), experiment, timepoint], env=env)
        if not matrix_wig.is_file():
            raise FileNotFoundError(f"HyperTRIBE did not create expected matrix: {matrix_wig}")
        matrix_wig.replace(matrix)
        run([perl, str(loader), "-t", table, "-d", str(matrix)], env=env)


def sql_section(sql_path: Path, assay: str) -> str:
    text = sql_path.read_text(encoding="utf-8-sig")
    marker_bulk = "# 2025 editing site calling (BULK)"
    marker_sc = "# 2025 editing site calling (single cell)"
    if marker_bulk not in text or marker_sc not in text:
        raise ValueError(f"Expected SQL section markers are missing in {sql_path}")
    bulk_start = text.index(marker_bulk) + len(marker_bulk)
    sc_start = text.index(marker_sc)
    if assay == "bulk":
        return text[bulk_start:sc_start]
    statements = text[text.index(marker_sc) + len(marker_sc):].split(";")
    selected = []
    current_meip26 = {
        "MEIP26_SC_NB_G_ALL", "MEIP26_SC_NB_C_ALL",
        "MEIP26_SC_Glia_G_ALL", "MEIP26_SC_Glia_C_ALL",
        "MEIP26_SC_INP_G_ALL", "MEIP26_SC_INP_C_ALL",
        "MEIP26_SC_GMCT1_G_ALL", "MEIP26_SC_GMCT1_C_ALL",
        "MEIP26_SC_GMCT2_G_ALL", "MEIP26_SC_GMCT2_C_ALL",
        "MEIP26_SC_Neuron_T1T2_G_ALL", "MEIP26_SC_Neuron_T1T2_C_ALL",
        "MEIP26_SC_Neuron_else_G_ALL", "MEIP26_SC_Neuron_else_C_ALL",
    }
    for statement in statements:
        match = re.search(r"(?i)\bCREATE\s+TABLE\s+([A-Za-z_][A-Za-z0-9_]*)", statement)
        if not match:
            continue
        table = match.group(1)
        if table.startswith(("SC_COR_CTRL_", "BRAT_SC_DIM15_")) or table in current_meip26:
            selected.append(statement.strip() + ";")
    return "\n\n".join(selected) + "\n"


def sql_source_tables(sql_text: str) -> set[str]:
    without_comments = re.sub(r"(?s)/\*.*?\*/", "", sql_text)
    without_comments = "\n".join(
        line for line in without_comments.splitlines()
        if not line.lstrip().startswith(("#", "--"))
    )
    return set(re.findall(r"(?i)\bFROM\s+`?([A-Za-z_][A-Za-z0-9_]*)`?", without_comments))


def run_sql(rows: list[dict[str, str]], config: dict, assay: str, outdir: Path) -> Path:
    sql_path = resolve_path(config.get("calling_sql", str(CODE / "call_edit_sites.sql")), config)
    if sql_path is None or not sql_path.is_file():
        raise FileNotFoundError(f"Calling SQL not found: {sql_path}")
    mysql = config.get("mysql", "mysql")
    sql_out = outdir / f"{assay}_call.sql"
    sql_out.parent.mkdir(parents=True, exist_ok=True)
    section_sql = sql_section(sql_path, assay)
    sql_out.write_text(section_sql, encoding="utf-8")
    # Calling SQL uses fixed CREATE TABLE names. Report existing tables because
    # this legacy SQL is intended for a fresh schema and is not idempotent.
    existing = existing_tables(config)
    missing_sources = sorted(sql_source_tables(section_sql) - existing)
    if missing_sources:
        raise ValueError(
            "Calling SQL source tables are missing from the configured database: "
            + ", ".join(missing_sources)
        )
    target_tables = set(re.findall(r"(?im)^\s*CREATE\s+TABLE\s+([A-Za-z_][A-Za-z0-9_]*)", section_sql))
    collisions = sorted(existing & target_tables)
    if collisions:
        raise ValueError(
            "Calling SQL output tables already exist; use a clean database/schema to avoid stale results: "
            + ", ".join(collisions[:10])
        )
    # Pipe SQL on stdin without involving a shell.
    print("+", shlex.join([mysql, f"--host={MYSQL_HOST}", f"--user={MYSQL_USER}", MYSQL_DATABASE,
                          "<", str(sql_out)]), flush=True)
    with sql_out.open("rb") as handle:
        subprocess.run([mysql, f"--host={MYSQL_HOST}", f"--user={MYSQL_USER}", MYSQL_DATABASE],
                       stdin=handle, check=True)
    return sql_out


def export_bulk_r_inputs(config: dict, outdir: Path) -> Path:
    r_script = resolve_path(config.get("bulk_r_script", str(CODE / "bulk" / "bulk_edit_identification.R")), config)
    mysql = config.get("mysql", "mysql")
    if r_script is None or not r_script.is_file():
        raise FileNotFoundError(f"Bulk R script not found: {r_script}")
    data_dir = outdir / "bulk" / "BULK_data"
    data_dir.mkdir(parents=True, exist_ok=True)
    filenames = sorted(set(re.findall(r'"(?:[^"\n]*/)?([A-Za-z0-9_]+\.txt)"', r_script.read_text(encoding="utf-8"))))
    if not filenames:
        raise ValueError(f"No SQL export filenames found in {r_script}")
    for filename in filenames:
        table = filename[:-4]
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", table):
            raise ValueError(f"Unsafe table name derived from R input filename: {filename}")
        query = [mysql, f"--host={MYSQL_HOST}", f"--user={MYSQL_USER}", "--batch", "--raw",
                 f"--execute=SELECT * FROM `{table}`", MYSQL_DATABASE]
        print("+", shlex.join(query), ">", data_dir / filename, flush=True)
        with (data_dir / filename).open("w", encoding="utf-8") as out:
            subprocess.run(query, stdout=out, check=True)
    return data_dir


def run_bulk_r(config: dict, data_dir: Path, outdir: Path) -> None:
    r_script = resolve_path(config.get("bulk_r_script", str(CODE / "bulk" / "bulk_edit_identification.R")), config)
    annotation = resolve_path(config.get("gene_annotation_bed"), config)
    if annotation is None or not annotation.is_file():
        raise FileNotFoundError("Set gene_annotation_bed to the dmel-all-r6.54.bed used by the original pipeline")
    output_dir = outdir / "bulk" / "OUTPUT"
    output_dir.mkdir(parents=True, exist_ok=True)
    run([config.get("rscript", "Rscript"), str(r_script), str(data_dir), str(output_dir)])


def annotate_bulk_sites(config: dict, outdir: Path) -> None:
    """Reproduce the gene-hit and strand filtering recorded in niagara.bash."""
    annotation = resolve_path(config.get("gene_annotation_bed"), config)
    if annotation is None or not annotation.is_file():
        raise FileNotFoundError("Set gene_annotation_bed to the dmel-all-r6.54.bed used by the original pipeline")
    bedtools = config.get("bedtools", "bedtools")
    output_dir = outdir / "bulk" / "OUTPUT"
    samples = (
        ("BRAT_TRIBE_BULK_cor.bed", "BRAT_TRIBE_BULK_sort_cor.bed",
         "BRAT_TRIBE_BULK_hit_cor.bed", "BRAT_TRIBE_BULK_genehit_cor.bed",
         "BRAT_TRIBE_BULK_genehit_strand_cor.bed"),
        ("MEIP26_TRIBE_BULK_ex4o_cor.bed", "MEIP26_TRIBE_BULK_ex4o_sort_cor.bed",
         "MEIP26_TRIBE_BULK_ex4o_hit_cor.bed", "MEIP26_TRIBE_BULK_ex4o_genehit_cor.bed",
         "MEIP26_TRIBE_BULK_ex4o_genehit_strand_cor.bed"),
    )
    for source_name, sorted_name, hits_name, gene_hits_name, strand_hits_name in samples:
        source = output_dir / source_name
        if not source.is_file():
            raise FileNotFoundError(f"Bulk site BED not found: {source}")
        sorted_bed = output_dir / sorted_name
        hits_bed = output_dir / hits_name
        gene_hits_bed = output_dir / gene_hits_name
        strand_hits_bed = output_dir / strand_hits_name
        with sorted_bed.open("w", encoding="utf-8") as handle:
            subprocess.run([bedtools, "sort", "-i", str(source)], cwd=output_dir,
                           check=True, text=True, stdout=handle)
        with hits_bed.open("w", encoding="utf-8") as handle:
            subprocess.run([bedtools, "intersect", "-a", str(annotation), "-b", str(sorted_bed), "-wa", "-wb"],
                           cwd=output_dir, check=True, text=True, stdout=handle)
        with hits_bed.open(encoding="utf-8") as src, gene_hits_bed.open("w", encoding="utf-8") as dst:
            for line in src:
                if "FlyBase.gene" in line:
                    dst.write(line)
        with gene_hits_bed.open(encoding="utf-8") as src, strand_hits_bed.open("w", encoding="utf-8") as dst:
            for line in src:
                columns = line.rstrip("\n").split("\t")
                if len(columns) >= 16 and columns[5] == columns[15]:
                    dst.write(line)


def mysql_sites(config: dict, table: str) -> set[tuple[str, int]]:
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", table):
        raise ValueError(f"Unsafe SQL table name: {table}")
    command = [config.get("mysql", "mysql"), f"--host={MYSQL_HOST}", f"--user={MYSQL_USER}",
               "--batch", "--skip-column-names", "--execute=SELECT chr, coord FROM `" + table + "`",
               MYSQL_DATABASE]
    result = subprocess.run(command, check=True, text=True, capture_output=True)
    sites: set[tuple[str, int]] = set()
    for line in result.stdout.splitlines():
        fields = line.split("\t")
        if len(fields) < 2:
            continue
        try:
            sites.add((fields[0], int(float(fields[1]))))
        except ValueError:
            # mysql's historical SELECT * exports included a header; the R
            # scripts remove it through na.omit() before writing BED.
            continue
    return sites


def identify_single_cell(config: dict, outdir: Path) -> None:
    """Recreate the reference BRAT-sc.r / MEIP26-sc.r site and gene-hit outputs."""
    annotation = resolve_path(config.get("gene_annotation_bed"), config)
    if annotation is None or not annotation.is_file():
        raise FileNotFoundError("Set gene_annotation_bed to the dmel-all-r6.54.bed used by the original pipeline")
    bedtools = config.get("bedtools", "bedtools")
    mysql = config.get("mysql", "mysql")
    groups = {
        "BRAT": {
            "controls": ([f"SC_COR_CTRL_{kind}_REP_{rep}_Aref" for kind in ("INSC", "YH98") for rep in range(1, 4)],
                         [f"SC_COR_CTRL_{kind}_REP_{rep}_Tref" for kind in ("INSC", "YH98") for rep in range(1, 4)]),
            "cells": [("NB", "BRAT_SC_DIM15_NB", "BRAT_DIM15_NB", "DIM15_NB"),
                      ("Glia_T1T2", "BRAT_SC_DIM15_Glia_T1T2", "BRAT_DIM15_Glia_T1T2", "DIM15_Glia_T1T2"),
                      ("Glia_else", "BRAT_SC_DIM15_Glia_else", "BRAT_DIM15_Glia_else", "DIM15_Glia_else"),
                      ("INP", "BRAT_SC_DIM15_INP", "BRAT_DIM15_INP", "DIM15_INP"),
                      ("GMCT1", "BRAT_SC_DIM15_GMCT1", "BRAT_DIM15_GMCT1", "DIM15_GMCT1"),
                      ("GMCT2", "BRAT_SC_DIM15_GMCT2", "BRAT_DIM15_GMCT2", "DIM15_GMCT2"),
                      ("Neuron_T1T2", "BRAT_SC_DIM15_Neuron_T1T2", "BRAT_DIM15_Neuron_T1T2", "DIM15_Neuron_T1T2"),
                      ("Neuron_else_1", "BRAT_SC_DIM15_Neuron_else_1", "BRAT_DIM15_Neuron_else_1", "DIM15_Neuron_else_1"),
                      ("Neuron_else_2", "BRAT_SC_DIM15_Neuron_else_2", "BRAT_DIM15_Neuron_else_2", "DIM15_Neuron_else_2")],
        },
        "MEIP26": {
            "controls": ([f"SC_COR_CTRL_{kind}_REP_{rep}_Aref" for kind in ("EX4O", "INSC") for rep in range(1, 4)],
                         [f"SC_COR_CTRL_{kind}_REP_{rep}_Tref" for kind in ("EX4O", "INSC") for rep in range(1, 4)]),
            "cells": [("NB", "MEIP26_SC_NB", "MEIP26_p0083_NB", "NB"),
                      ("Glia", "MEIP26_SC_Glia", "MEIP26_p0083_Glia", "Glia"),
                      ("INP", "MEIP26_SC_INP", "MEIP26_p0083_INP", "INP"),
                      ("GMCT1", "MEIP26_SC_GMCT1", "MEIP26_p0083_GMCT1", "GMCT1"),
                      ("GMCT2", "MEIP26_SC_GMCT2", "MEIP26_p0083_GMCT2", "GMCT2"),
                      ("Neuron_T1T2", "MEIP26_SC_Neuron_T1T2", "MEIP26_Neuron_T1T2", "Neuron_T1T2"),
                      ("Neuron_else", "MEIP26_SC_Neuron_else", "MEIP26_Neuron_else", "Neuron_else"),
                      ],
        },
    }
    root = outdir / "single_cell"
    for assay, spec in groups.items():
        result_dir = root / assay / "TRIBE_edits"
        result_dir.mkdir(parents=True, exist_ok=True)
        aref_tables, tref_tables = spec["controls"]
        # niagara.bash requires each site in all six Bonferroni-corrected
        # control tables, then intersects that set with the cell-type G/C set.
        aref = set.intersection(*(mysql_sites(config, table) for table in aref_tables))
        tref = set.intersection(*(mysql_sites(config, table) for table in tref_tables))
        (result_dir / f"SC_p0083_{assay}_Celltype_Aref.txt").write_text(
            "".join(f"{chrom}\t{coord}\n" for chrom, coord in sorted(aref)), encoding="utf-8")
        (result_dir / f"SC_p0083_{assay}_Celltype_Tref.txt").write_text(
            "".join(f"{chrom}\t{coord}\n" for chrom, coord in sorted(tref)), encoding="utf-8")
        for celltype, source, text_prefix, bed_prefix in spec["cells"]:
            ag = aref & mysql_sites(config, source + "_G_ALL")
            tc = tref & mysql_sites(config, source + "_C_ALL")
            for label, sites in (("AtoG", ag), ("TtoC", tc)):
                (result_dir / f"{text_prefix}_{label}.txt").write_text(
                    "".join(f"{chrom}\t{coord}\n" for chrom, coord in sorted(sites)), encoding="utf-8")
            bed = result_dir / f"{bed_prefix}_edit.bed"
            with bed.open("w", encoding="utf-8") as handle:
                for strand, sites in (("+", ag), ("-", tc)):
                    for chrom, coord in sorted(sites):
                        # Match the reference R scripts: use coord as BED start,
                        # coord + 1 as end, and infer strand from edit class.
                        handle.write(f"{chrom}\t{coord}\t{coord + 1}\t.\t.\t{strand}\n")
            # niagara.bash names these <celltype>_edit_sort.bed.
            sorted_bed = result_dir / f"{bed_prefix}_edit_sort.bed"
            hits_bed = result_dir / f"{bed_prefix}_hits.bed"
            gene_hits = result_dir / f"{assay}_{bed_prefix}_genehits.bed"
            strand_hits = result_dir / f"{assay}_{bed_prefix}_genehits_strand.bed"
            with sorted_bed.open("w", encoding="utf-8") as dst:
                subprocess.run([bedtools, "sort", "-i", str(bed)], cwd=result_dir, check=True, text=True, stdout=dst)
            with hits_bed.open("w", encoding="utf-8") as dst:
                subprocess.run([bedtools, "intersect", "-a", str(annotation), "-b", str(sorted_bed), "-wa", "-wb"],
                               cwd=result_dir, check=True, text=True, stdout=dst)
            with hits_bed.open(encoding="utf-8") as src, gene_hits.open("w", encoding="utf-8") as dst:
                for line in src:
                    if "FlyBase.gene" in line:
                        dst.write(line)
            with gene_hits.open(encoding="utf-8") as src, strand_hits.open("w", encoding="utf-8") as dst:
                for line in src:
                    columns = line.rstrip("\n").split("\t")
                    if len(columns) >= 16 and columns[5] == columns[15]:
                        dst.write(line)
def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    parser.add_argument("--config", required=True, type=Path, help="JSON pipeline configuration")
    parser.add_argument("--manifest", required=True, type=Path, help="Tab-delimited sample manifest")
    parser.add_argument("--assay", required=True, choices=("bulk", "single_cell"))
    parser.add_argument("--stage", default="all", choices=("preprocess", "matrix", "call", "identify", "all"))
    args = parser.parse_args()

    config = read_config(args.config.resolve())
    manifest = args.manifest.resolve()
    outdir = resolve_path(config.get("output_dir", "output"), config)
    assert outdir is not None
    outdir.mkdir(parents=True, exist_ok=True)
    rows = read_manifest(manifest, args.assay)

    if args.stage in ("matrix", "call", "identify", "all"):
        ensure_database(config)

    if args.stage in ("preprocess", "all"):
        if args.assay == "bulk":
            prepare_bulk(rows, config, outdir)
        else:
            prepare_single_cell(rows, config, outdir)

    if args.stage in ("matrix", "all"):
        load_matrices(rows, config, args.assay)
    if args.stage in ("call", "all") or (args.assay == "single_cell" and args.stage == "identify"):
        run_sql(rows, config, args.assay, outdir)
    if args.assay == "bulk" and args.stage in ("identify", "all"):
        data_dir = export_bulk_r_inputs(config, outdir)
        run_bulk_r(config, data_dir, outdir)
        annotate_bulk_sites(config, outdir)
    elif args.assay == "single_cell" and args.stage in ("identify", "all"):
        identify_single_cell(config, outdir)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"Pipeline stopped: {exc}", file=sys.stderr)
        raise SystemExit(1)
