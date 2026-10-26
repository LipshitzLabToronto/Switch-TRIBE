# Manual execution protocol

Use this protocol when running the workflow step by step on a local or cluster-specific MySQL/MariaDB installation. It follows the same HyperTRIBE convention used by the runner and does not require a particular scheduler or container system.

The required MySQL schema is `dmseq`. The loader follows HyperTRIBE's historical connection convention: `localhost`, user `root`, empty password. Configure the local client/server in the manner appropriate to the execution environment before running the commands below.

## 1. Generate high-quality SAM files

### Bulk

For each row of `pipeline_manifest_bulk.tsv`, provide the released single-end bulk FASTQ path in the `fastq` column, then run the recorded HyperTRIBE bulk route:

```sh
python3 run_pipeline.py --config pipeline_config.json \
  --manifest pipeline_manifest_bulk.tsv --assay bulk --stage preprocess
```

**Input:** one single-end bulk FASTQ per manifest row, r6.60 FASTA/GTF.

**Output:** `run_output/bulk/<sample_id>/<sample_id>_rmdup_sorted.sam`.

The produced SAM is MAPQ-filtered at 10, coordinate sorted, passed through Picard `MarkDuplicates` with `REMOVE_DUPLICATES=true`, and sorted again. This matches the `*_rmdup_sorted.sam` files passed to the historical bulk loaders.

### Single-cell

Run this section only after completing the bulk calling and bulk identification commands in sections 4 and 5, because MEI-P26 preprocessing requires the bulk MEI-P26 edit BED.

Set the released BRAT and MEI-P26 paired R1/R2 FASTQ paths in `pipeline_config.json`, then run:

```sh
python3 run_pipeline.py --config pipeline_config.json \
  --manifest pipeline_manifest_single_cell.tsv --assay single_cell --stage preprocess
```

**Inputs:** raw paired FASTQ, final cluster barcode tables, r6.60 FASTA/GTF, and r6.54 FASTA/BED.

**Outputs:** recovered TRIBE R1/R2 files in `run_output/single_cell/<assay>/recovery/`, then the final nine BRAT and seven MEI-P26 cell-type high-quality SAM files in `run_output/single_cell/<assay>/sam/`.  The final MEI-P26 R2 is `MEIP26_TRIBE_ALL_R2.fastq.gz`, matching the later pairing and STAR commands that read it with `zcat`.

Run bulk preprocessing and edit identification before MEI-P26 single-cell preprocessing because the MEI-P26 target-pattern step uses `run_output/bulk/OUTPUT/MEIP26_TRIBE_BULK_ex4o_cor.bed`.

## 2. Convert each SAM into a HyperTRIBE matrix

For every SAM from step 1, run the original HyperTRIBE matrix converter. Use the `experiment` and `timepoint` values from the corresponding pipeline manifest row; the supplied manifests use `rnalibs` and `1`.

```sh
perl third_party/HyperTRIBE/CODE/sam_to_matrix.pl \
  /absolute/path/to/sample_rmdup_sorted.sam rnalibs 1
mv /absolute/path/to/sample_rmdup_sorted.sam.matrix.wig \
  /absolute/path/to/sample.matrix
```

**Input:** one high-quality SAM.

**Output:** one ten-column matrix with `experiment`, `time`, chromosome, coordinate, A/T/C/G/N counts, and total count.

## 3. Load each matrix into local MySQL/MariaDB

Create the schema once if it does not already exist:

```sh
mysql --host=localhost --user=root --execute='CREATE DATABASE IF NOT EXISTS `dmseq`'
```

For every matrix, use its exact `table_name` from the manifest:

```sh
perl code/loaders/load_matrix_data_configurable.pl \
  -t BRAT_BULK_REP_1 \
  -d /absolute/path/to/BRAT_TRIBE_rep1.matrix
```

**Input:** the matrix from step 2.

**MySQL output:** one `dmseq.<table_name>` count table with primary key `(experiment, time, chr, coord)` and columns `Acount`, `Tcount`, `Ccount`, `Gcount`, `Ncount`, and `totalcount`.

Repeat this command for every bulk sample, bulk control, and each of the 16 final single-cell cell types. The supplied manifests define the required table names.

## 4. Create calling tables

The runner extracts and executes only the appropriate section of `code/call_edit_sites.sql`, checks source tables, and writes the executed SQL to `run_output/<assay>_call.sql`.

After all bulk matrices have been loaded:

```sh
python3 run_pipeline.py --config pipeline_config.json \
  --manifest pipeline_manifest_bulk.tsv --assay bulk --stage call
```

**MySQL output:** bulk A-to-G/T-to-C candidate tables and BRAT/MEI-P26 control reference tables.

For single-cell, do not run `--stage call` as a separate preparatory command. The `--stage identify` command in step 5 creates the required `SC_COR_CTRL_*` and final cell-type `_G_ALL` / `_C_ALL` tables, then immediately consumes them to write the final files.

## 5. Write final editing-site files

For bulk, execute the R-based identification and annotation after the bulk calling tables exist:

```sh
python3 run_pipeline.py --config pipeline_config.json \
  --manifest pipeline_manifest_bulk.tsv --assay bulk --stage identify
```

**Output:** `run_output/bulk/OUTPUT/BRAT_TRIBE_BULK_cor.bed`, `MEIP26_TRIBE_BULK_ex4o_cor.bed`, and their gene-hit/strand-filtered BED files.

For single-cell, execute the control intersections and annotation after all 16 cell-type matrices and required bulk controls have been loaded. This command first creates the required single-cell calling tables:

```sh
python3 run_pipeline.py --config pipeline_config.json \
  --manifest pipeline_manifest_single_cell.tsv --assay single_cell --stage identify
```

**Output:** cell-type A-to-G and T-to-C lists, BED files, gene-hit BED files, and strand-filtered gene-hit BED files in `run_output/single_cell/{BRAT,MEIP26}/TRIBE_edits/`.

If using `--stage all`, do not run the corresponding separate `call` command first: table-collision protection will correctly stop a second creation attempt.
