#!/usr/bin/env bash
# Reconstruct the single-end bulk HyperTRIBE preprocessing route recorded in
# the original HyperTRIBE trim_and_align.sh.  22mis1 is a single-cell-derived
# test dataset and is deliberately not used here.
set -euo pipefail

if [[ $# -ne 9 ]]; then
  echo "Usage: $0 SAMPLE_ID INPUT_FASTQ STAR_INDEX OUTPUT_DIR TRIMMOMATIC PICARD STAR SAMTOOLS THREADS" >&2
  exit 2
fi

sample_id=$1
input_fastq=$2
star_index=$3
output_dir=$4
trimmomatic=$5
picard=$6
star=$7
samtools=$8
threads=$9

[[ -s "$input_fastq" ]] || { echo "Input FASTQ not found or empty: $input_fastq" >&2; exit 1; }
[[ -d "$star_index" ]] || { echo "STAR index not found: $star_index" >&2; exit 1; }

mkdir -p "$output_dir/trimmed" "$output_dir/star" "$output_dir/samtools" "$output_dir/picard_tmp"
trimmed_fastq="$output_dir/trimmed/${sample_id}.trim.fastq.gz"
star_prefix="$output_dir/star/${sample_id}_"
high_quality_sam="$output_dir/samtools/${sample_id}_highquality.sam"
sorted_bam="$output_dir/samtools/${sample_id}.sorted.bam"
deduplicated_bam="$output_dir/samtools/${sample_id}.nodup.bam"
final_bam="$output_dir/samtools/${sample_id}.rmdup.sorted.bam"
metrics="$output_dir/samtools/${sample_id}.duplicate_metrics.txt"
final_sam="$output_dir/${sample_id}_rmdup_sorted.sam"

# Exact bulk HyperTRIBE trimming parameters.
"$trimmomatic" SE -phred33 "$input_fastq" "$trimmed_fastq" \
  HEADCROP:6 LEADING:25 TRAILING:25 AVGQUAL:25 MINLEN:19

"$star" --runThreadN "$threads" \
  --outFilterMismatchNoverLmax 0.07 \
  --outFileNamePrefix "$star_prefix" \
  --outFilterMatchNmin 16 \
  --outFilterMultimapNmax 1 \
  --genomeDir "$star_index" \
  --readFilesIn "$trimmed_fastq" \
  --readFilesCommand zcat

"$samtools" view -@ 4 -Sh -q 10 "${star_prefix}Aligned.out.sam" > "$high_quality_sam"
"$samtools" view -@ 4 -bhS "$high_quality_sam" > "$output_dir/samtools/${sample_id}.bam"
"$samtools" sort -@ 6 "$output_dir/samtools/${sample_id}.bam" -o "$sorted_bam"

# The legacy bulk pipeline removes PCR duplicates before matrix construction.
"$picard" MarkDuplicates \
  INPUT="$sorted_bam" OUTPUT="$deduplicated_bam" METRICS_FILE="$metrics" \
  VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true \
  TMP_DIR="$output_dir/picard_tmp" ASSUME_SORTED=true
"$samtools" sort -@ 6 "$deduplicated_bam" -o "$final_bam"
"$samtools" view -@ 4 -h "$final_bam" > "$final_sam"
"$samtools" index "$final_bam"

echo "Created $final_sam"
