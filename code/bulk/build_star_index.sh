#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 6 ]]; then
  echo "Usage: $0 GENOME_FASTA GTF_OR_DASH INDEX_DIR THREADS SJDB_OVERHANG STAR" >&2
  exit 2
fi

genome_fasta=$1
genome_gtf=$2
index_dir=$3
threads=$4
sjdb_overhang=$5
star=$6

# Match the STAR 2.7.11b r6.60 genomeGenerate record when the pipeline runs
# on a module-based cluster. On other systems, STAR is taken from PATH.
if type module >/dev/null 2>&1; then
  module load CCEnv
  module load StdEnv/2023
  module load star/2.7.11b
fi

mkdir -p "$index_dir"
if [[ "$genome_gtf" == "-" ]]; then
  "$star" --runThreadN "$threads" --runMode genomeGenerate \
    --genomeDir "$index_dir" --genomeFastaFiles "$genome_fasta" \
    --sjdbOverhang "$sjdb_overhang"
else
  "$star" --runThreadN "$threads" --runMode genomeGenerate \
    --genomeDir "$index_dir" --genomeFastaFiles "$genome_fasta" \
    --sjdbGTFfile "$genome_gtf" --sjdbOverhang "$sjdb_overhang"
fi
