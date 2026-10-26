# Reproduction inputs and included resources

This directory contains every project-specific code and non-public resource
needed by the edit-identification workflow. Copy this directory unchanged when
depositing the reproducibility package.

## Included in this directory

- Bulk and single-cell preprocessing, calling, and identification code.
- The final 23 BRAT and 28 MEI-P26 cluster barcode tables in
  `resources/cell_type_barcodes/`.
- The final cluster-to-cell-type mapping in
  `code/single_cell/cell_type_annotation.md`.
- HyperTRIBE `sam_to_matrix.pl` and its MIT license in
  `third_party/HyperTRIBE/`.
- Manifests specifying every required count-table identity and the final 16
  single-cell outputs.

## Supplied separately by the reproducer

| Item | Required form | Where to configure it |
|---|---|---|
| Deposited raw reads | Historical single-end bulk FASTQ files and BRAT/MEI-P26 paired R1/R2 FASTQ files | `pipeline_manifest_bulk.tsv` and `single_cell_inputs` in `pipeline_config.json` |
| Public alignment reference | FlyBase r6.60 FASTA and GTF | `genome_fasta`, `genome_gtf` |
| Public annotation reference | FlyBase r6.54 FASTA and BED | `annotation_fasta`, `gene_annotation_bed` |
| Software | Conda environment based on `environment.yml`, with MySQL/MariaDB running locally | executable keys in `pipeline_config.json` |

The runner builds the STAR index from the supplied r6.60 FASTA/GTF. It creates
and uses the local `dmseq` schema following HyperTRIBE's documented convention.
The ordered manual database procedure is in `MANUAL_EXECUTION.md`.

No precomputed SAM, matrix, database table, BED, or plot is required as an
input: those are produced in the documented order from deposited reads.
