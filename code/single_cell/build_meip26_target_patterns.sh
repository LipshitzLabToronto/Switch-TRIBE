#!/usr/bin/env bash
# Reproduce niagara.bash lines 1111--1145: derive the MEI-P26 R2 search
# patterns from the reference edit-site BED, annotation and genome FASTA.
set -euo pipefail

if [[ $# -ne 6 ]]; then
  echo "Usage: $0 REFSITE_BED GENE_ANNOTATION_BED GENOME_FASTA OUTPUT_TAB BEDTOOLS WORKDIR" >&2
  exit 2
fi

refsite_bed=$1
annotation_bed=$2
genome_fasta=$3
output_tab=$4
bedtools=$5
workdir=$6
mkdir -p "$workdir"

for input in "$refsite_bed" "$annotation_bed" "$genome_fasta"; do
  [[ -s "$input" ]] || { echo "Required input not found or empty: $input" >&2; exit 1; }
done

sorted="$workdir/MEIP26_sc_REFSITE_sort.bed"
hits="$workdir/MEIP26_REFSITE_hits.bed"
gene_hits="$workdir/MEIP26_REFSITE_genehits.bed"
sites="$workdir/MEIP26_REFSITE_genehits_site.bed"
regions="$workdir/MEIP26_REFSITE_genehits_region.bed"
sequence="$workdir/MEIP26_REFSITE_sequence.fa"
reversed="$workdir/MEIP26_REFSITE_sequence_rev.fa"

"$bedtools" sort -i "$refsite_bed" > "$sorted"
"$bedtools" intersect -a "$annotation_bed" -b "$sorted" -wa -wb > "$hits"
sed -n '/FlyBase.gene/p' "$hits" > "$gene_hits"
awk '{print $14, $15, $19}' "$gene_hits" > "$sites"
awk -v OFS='\t' '{start=$2-14; end=$2+15; if (start < 0) start = 0; print $1, start, end, ".", ".", $3}' "$sites" > "$regions"
"$bedtools" getfasta -fi "$genome_fasta" -bed "$regions" -fo "$sequence" -s

paste - - < "$sequence" | while read -r header seq; do
  echo "$header"
  if [[ "$header" == *"(-)"* ]]; then
    echo "$seq" | rev
  else
    echo "$seq"
  fi
done > "$reversed"

# Keep reference-A centres, use the 25 nt around the centre, and substitute
# the thirteenth base A->G exactly as in the final MEIP26 recovery route.
awk 'substr($0, 14, 1) == "A" { print substr($0, 2, 25) }' "$reversed" |
  awk '{ $0 = substr($0, 1, 12) "G" substr($0, 14); print }' > "$output_tab"
sed -i.bak '1i\
GCATAACTTCGTATAGCATACATTATACGAAGTTATCG
' "$output_tab"
rm -f "${output_tab}.bak"
