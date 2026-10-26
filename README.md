# Switch-TRIBE edit-identification reproducibility pipeline

[![Release metadata](https://img.shields.io/badge/release-0.1.0-blue)](CITATION.cff)

This repository contains the computational workflow used to reproduce editing-site identification in the Switch-TRIBE study. It covers bulk and single-cell processing from raw sequencing reads through alignment, per-site nucleotide counting, SQL calling, statistical filtering, BED generation, and gene-hit annotation. It does not include downstream summaries, plots, or manuscript figure generation.

> **Contact.** If you encounter any problem while running this code, please contact the authors promptly at **`huyichao@westlake.edu.cn`**.

## Repository layout

| Path | Purpose |
|---|---|
| [`run_pipeline.py`](run_pipeline.py) | Command-line entry point for bulk and single-cell processing. |
| [`pipeline_config.example.json`](pipeline_config.example.json) | Configuration template. Copy it before editing. |
| [`pipeline_manifest_bulk.tsv`](pipeline_manifest_bulk.tsv) | Bulk sample-to-count-table mapping. |
| [`pipeline_manifest_single_cell.tsv`](pipeline_manifest_single_cell.tsv) | Final BRAT/MEI-P26 cell-type count-table mapping. |
| [`code/bulk/`](code/bulk) | STAR-index construction, bulk FASTQ-to-SAM processing, and bulk edit identification in R. |
| [`code/single_cell/`](code/single_cell) | Read recovery, MEI-P26 target-pattern generation, final cell-type barcode mapping, STAR, and MAPQ filtering. |
| [`code/call_edit_sites.sql`](code/call_edit_sites.sql) | Bulk and single-cell SQL calling logic. |
| [`code/loaders/load_matrix_data_configurable.pl`](code/loaders/load_matrix_data_configurable.pl) | Loader invoked by the runner after HyperTRIBE matrix generation. |
| [`resources/cell_type_barcodes/`](resources/cell_type_barcodes) | Final BRAT and MEI-P26 cluster barcode tables used to form cell-type SAMs. |
| [`third_party/HyperTRIBE/CODE/`](third_party/HyperTRIBE/CODE) | Bundled MIT-licensed HyperTRIBE SAM-to-matrix converter. |
| [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) | Input contracts, run order, outputs, and verification points. |
| [`CODE_TRACEABILITY.md`](CODE_TRACEABILITY.md) | Source-to-release evidence for each reproducibility step. |

## Software environment

Use [`environment.yml`](environment.yml) as a starting point for a Conda environment. The original documented index build used STAR 2.7.11b. Archive an environment export or lockfile for the exact execution platform.

Required executables are `python3` (3.10 or newer), `Rscript`, `perl`, `mysql`, `STAR`, `samtools`, `seqkit`, `bedtools`, `trimmomatic`, `picard`, and Java. Perl requires `DBI` and `DBD::mysql`; R requires `dplyr`. The required HyperTRIBE converter is bundled in this directory.

## Reference assemblies

The historical workflow used two Drosophila reference releases for different operations. Keep these assignments unchanged.

| Configuration key | Required historical reference | Use |
|---|---|---|
| `genome_fasta` | `dmel-all-chromosome-r6.60.fasta` | STAR index construction and alignment |
| `genome_gtf` | `dmel-all-r6.60.gtf` | STAR splice-junction annotation |
| `annotation_fasta` | `dmel-all-chromosome-r6.54.fasta` | MEI-P26 25-nt target-pattern generation |
| `gene_annotation_bed` | `dmel-all-r6.54.bed` | BED gene-hit and strand-consistency annotation |


## Quick start

1. Copy and edit the configuration.

   ```sh
   cp pipeline_config.example.json pipeline_config.json
   ```

2. Put the publicly released raw files at paths with the historical filenames used in the manifests and configuration. Set those paths, the public reference versions, and tool paths. The bundled barcode and HyperTRIBE paths already work unchanged. The bulk manifest defines the required sample, control, replicate, and MySQL table identities.

3. Run bulk processing before single-cell preprocessing.

   ```sh
   python3 run_pipeline.py --config pipeline_config.json \
     --manifest pipeline_manifest_bulk.tsv --assay bulk --stage all
   ```

4. Run the final single-cell workflow.

   ```sh
   python3 run_pipeline.py --config pipeline_config.json \
     --manifest pipeline_manifest_single_cell.tsv --assay single_cell --stage all
   ```

The single-cell SQL and edit-identification stages require count tables for BRAT INSC/YH98 and MEI-P26 EX4O/INSC controls. Load these through the bulk workflow first. [`MANUAL_EXECUTION.md`](MANUAL_EXECUTION.md) documents the equivalent SAM → matrix → MySQL → SQL route for users who run each step manually on their own cluster.

