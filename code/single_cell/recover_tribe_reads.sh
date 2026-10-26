#!/usr/bin/env bash
# Reconstruct the recorded raw paired FASTQ -> paired TRIBE-read FASTQ step.
set -euo pipefail

if [[ $# -ne 8 ]]; then
  echo "Usage: $0 ASSAY RAW_R1 RAW_R2 OUTPUT_DIR SEQKIT THREADS PARTS PATTERN_FILE" >&2
  exit 2
fi

assay=$1
raw_r1=$2
raw_r2=$3
output_dir=$4
seqkit=$5
threads=$6
parts=$7
pattern_file=$8

for input in "$raw_r1" "$raw_r2" "$pattern_file"; do
  [[ -s "$input" ]] || { echo "Required input not found or empty: $input" >&2; exit 1; }
done

mkdir -p "$output_dir"
candidate_r2="$output_dir/candidate_R2.fastq"
pair_r1_dir="$output_dir/pair_candidate_R1"
pair_r2_dir="$output_dir/pair_final_R2"
split_r1="$output_dir/raw_R1.split"
split_r2="$output_dir/raw_R2.split"
initial_r1="$output_dir/candidate_R1.fastq.gz"
barcode_file="$output_dir/TRIBE.unique.barcode"

# BRAT 1_find_TRIBE_ex.sh also enables case-insensitive matching.  MEIP26's
# final script uses its generated multi-pattern tab without that option.
if [[ "$assay" == "BRAT" ]]; then
  "$seqkit" grep -P -s -i -f "$pattern_file" --threads "$threads" "$raw_r2" > "$candidate_r2"
else
  "$seqkit" grep -P -s -f "$pattern_file" --threads "$threads" "$raw_r2" > "$candidate_r2"
fi
"$seqkit" split2 "$raw_r1" -p "$parts" --threads "$threads" -O "$split_r1"
"$seqkit" split2 "$raw_r2" -p "$parts" --threads "$threads" -O "$split_r2"

mkdir -p "$pair_r1_dir" "$pair_r2_dir"
for fragment in "$split_r1"/*; do
  [[ -f "$fragment" ]] || continue
  "$seqkit" pair -1 "$fragment" -2 "$candidate_r2" --threads "$threads" -O "$pair_r1_dir/$(basename "$fragment")"
done
find "$pair_r1_dir" -type f -name '*R1*.fastq*' -print | sort | while IFS= read -r file; do
  cat "$file"
done > "$initial_r1"

# 2_pair_TRIBE.sh / 2_extractbarcode.sh then niagara.bash sort -u.
if [[ "$initial_r1" == *.gz ]]; then
  gzip -cd "$initial_r1" | awk 'NR % 4 == 2 {print substr($0, 1, 59)}' | sort -u > "$barcode_file"
else
  awk 'NR % 4 == 2 {print substr($0, 1, 59)}' "$initial_r1" | sort -u > "$barcode_file"
fi

case "$assay" in
  BRAT) final_r1="$output_dir/BRAT_TRIBE_R1.fastq.gz"; final_r2="$output_dir/BRAT_TRIBE_R2.fastq.gz" ;;
  # The final MEIP26_new pairing/STAR scripts consume this R2 stream as
  # MEIP26_TRIBE_ALL_R2.fastq.gz.  Its producer concatenates gzip members,
  # so preserve that gzip stream and its consumed filename here.
  MEIP26) final_r1="$output_dir/MEIP26_TRIBE_ALL_R1.fastq"; final_r2="$output_dir/MEIP26_TRIBE_ALL_R2.fastq.gz" ;;
  *) echo "Unsupported assay: $assay" >&2; exit 2 ;;
esac

"$seqkit" grep -P -f "$barcode_file" -R 1:59 --threads "$threads" "$raw_r1" > "$final_r1"
for fragment in "$split_r2"/*; do
  [[ -f "$fragment" ]] || continue
  "$seqkit" pair -1 "$fragment" -2 "$final_r1" --threads "$threads" -O "$pair_r2_dir/$(basename "$fragment")"
done
find "$pair_r2_dir" -type f -name '*R2*.fastq*' -print | sort | while IFS= read -r file; do
  cat "$file"
done > "$final_r2"

# Both final STAR routes use --readFilesCommand zcat.  Fail before alignment
# if the pair output no longer has the gzip stream recorded by the final jobs.
gzip -t "$final_r2"
