#!/usr/bin/env bash
# Reconstruct the final cell-type FASTQ -> SAM routes recorded in
# BRAT_new/ and MEIP26_new/.  The cluster combinations and tool parameters
# are copied from niagara.bash and those final job scripts.
set -euo pipefail

if [[ $# -ne 10 ]]; then
  echo "Usage: $0 ASSAY TRIBE_R1 TRIBE_R2 STAR_INDEX CLUSTER_BARCODES OUTPUT_DIR SEQKIT STAR SAMTOOLS THREADS" >&2
  exit 2
fi

assay=$1
r1_fastq=$2
r2_fastq=$3
star_index=$4
barcode_root=$5
output_dir=$6
seqkit=$7
star=$8
samtools=$9
threads=${10}

for input in "$r1_fastq" "$r2_fastq"; do
  [[ -s "$input" ]] || { echo "Input FASTQ not found or empty: $input" >&2; exit 1; }
done
[[ -d "$star_index" ]] || { echo "STAR index not found: $star_index" >&2; exit 1; }

case "$assay" in
  BRAT)
    barcode_dir="$barcode_root/BRAT"
    # Final BRAT dim15/res1.0 annotation: niagara.bash lines 1404--1425.
    celltypes=(NB INP GMCTI GMCTII Neuron_T1T2 Neuron_else_1 Neuron_else_2 Glia_T1T2 Glia_else)
    clusters_NB=(22)
    clusters_INP=(6 7 14 20)
    clusters_GMCTI=(8 15)
    clusters_GMCTII=(13)
    clusters_Neuron_T1T2=(1 2)
    clusters_Neuron_else_1=(3 4 21)
    clusters_Neuron_else_2=(18)
    clusters_Glia_T1T2=(12 16)
    clusters_Glia_else=(23)
    prefix=BRAT_dim15
    ;;
  MEIP26)
    barcode_dir="$barcode_root/MEI-P26"
    # Final MEIP26 T1/T2 annotation: niagara.bash lines 1661--1678.
    celltypes=(NB INP GMCTI GMCTII Neuron_T1T2 Neuron_else Glia)
    clusters_NB=(17)
    clusters_INP=(3 8 14 23)
    clusters_GMCTI=(9)
    clusters_GMCTII=(10 11)
    clusters_Neuron_T1T2=(1 2 13)
    clusters_Neuron_else=(4 6 7 20 24 26)
    clusters_Glia=(18 19 22 25 28)
    prefix=MEIP26
    ;;
  *)
    echo "Unsupported assay: $assay (expected BRAT or MEIP26)" >&2
    exit 2
    ;;
esac

[[ -d "$barcode_dir" ]] || { echo "Cluster barcode directory not found: $barcode_dir" >&2; exit 1; }

barcode_dir_out="$output_dir/barcodes"
fastq_dir="$output_dir/fastq"
sam_dir="$output_dir/sam"
mkdir -p "$barcode_dir_out" "$fastq_dir" "$sam_dir"

make_barcode_table() {
  local celltype=$1
  local table="$barcode_dir_out/${celltype}.tab"
  local cluster
  : > "$table"
  local cluster_var="clusters_${celltype}[@]"
  for cluster in "${!cluster_var}"; do
    local source="$barcode_dir/cluster_${cluster}_barcodes.tab"
    [[ -s "$source" ]] || { echo "Missing cluster barcode file: $source" >&2; exit 1; }
    # The supplied tables are Seurat 9_9_9 barcodes.  The historical
    # cell-type scripts replace each separator with 16 Ns before matching
    # the first 59 bases of the barcode read.
    tr -d '\r' < "$source" | sed 's/_/NNNNNNNNNNNNNNNN/g' >> "$table"
  done
}

select_pair_and_align() {
  local celltype=$1
  local table="$barcode_dir_out/${celltype}.tab"
  local sample_dir="$fastq_dir/$celltype"
  local selected_r1="$sample_dir/${prefix}_${celltype}_R1.fastq.gz"
  local selected_r2
  local star_prefix="$sam_dir/${prefix}_${celltype}_"
  local sam="$sam_dir/${prefix}_${celltype}_hq.sam"

  mkdir -p "$sample_dir"
  "$seqkit" grep -P -d -f "$table" -R 1:59 --threads "$threads" "$r1_fastq" > "$selected_r1"
  "$seqkit" pair -1 "$r2_fastq" -2 "$selected_r1" --threads "$threads" -O "$sample_dir"
  selected_r2=$(find "$sample_dir" -maxdepth 1 -type f -name '*R2*.fastq*' -print -quit)
  [[ -n "$selected_r2" ]] || { echo "seqkit pair did not create an R2 FASTQ for $celltype" >&2; exit 1; }
  # The recorded STAR calls use zcat for every final cell-type R2 FASTQ.
  gzip -t "$selected_r2"

  "$star" --runThreadN "$threads" \
    --outFilterMismatchNoverLmax 0.07 \
    --outFileNamePrefix "$star_prefix" \
    --outFilterMatchNmin 16 \
    --outFilterMultimapNmax 1 \
    --genomeDir "$star_index" \
    --readFilesIn "$selected_r2" \
    --readFilesCommand zcat
  "$samtools" view -@ 4 -Sh -q 10 "${star_prefix}Aligned.out.sam" > "$sam"
}

for celltype in "${celltypes[@]}"; do
  make_barcode_table "$celltype"
  select_pair_and_align "$celltype"
done
