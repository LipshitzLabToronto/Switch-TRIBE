# Final cell-type barcode annotation

`preprocess_celltype_sam.sh` uses the latest logged barcode-to-SAM branches:
`BRAT_new` and `MEIP26_new`.  Their cluster combinations are the final
commands in `niagara.bash`, rather than the earlier six-category branches.

| Assay | Output cell type | Source cluster barcode files |
|---|---|---|
| BRAT dim15/res1.0 | NB | 22 |
| BRAT dim15/res1.0 | INP | 6, 7, 14, 20 |
| BRAT dim15/res1.0 | GMCTI | 8, 15 |
| BRAT dim15/res1.0 | GMCTII | 13 |
| BRAT dim15/res1.0 | Neuron_T1T2 | 1, 2 |
| BRAT dim15/res1.0 | Neuron_else_1 | 3, 4, 21 |
| BRAT dim15/res1.0 | Neuron_else_2 | 18 |
| BRAT dim15/res1.0 | Glia_T1T2 | 12, 16 |
| BRAT dim15/res1.0 | Glia_else | 23 |
| MEI-P26 T1/T2 | NB | 17 |
| MEI-P26 T1/T2 | INP | 3, 8, 14, 23 |
| MEI-P26 T1/T2 | GMCTI | 9 |
| MEI-P26 T1/T2 | GMCTII | 10, 11 |
| MEI-P26 T1/T2 | Neuron_T1T2 | 1, 2, 13 |
| MEI-P26 T1/T2 | Neuron_else | 4, 6, 7, 20, 24, 26 |
| MEI-P26 T1/T2 | Glia | 18, 19, 22, 25, 28 |

The bundled source files in `../../resources/cell_type_barcodes/BRAT/` and
`../../resources/cell_type_barcodes/MEI-P26/` have the Seurat `9_9_9` barcode form.
The historical commands replace each underscore with sixteen `N` bases and
match the resulting 59 nt sequence against positions 1--59 of TRIBE R1.
The supplied files contain all cells in each cluster.  Selection still occurs
against the already recovered TRIBE-only R1/R2 pair, so a read must satisfy
both the TRIBE-read recovery step and its cell-type barcode match.

The R scripts also retain earlier, broader six-category mappings.  They are
not used by the final `BRAT_new`/`MEIP26_new` FASTQ/SAM jobs above.
