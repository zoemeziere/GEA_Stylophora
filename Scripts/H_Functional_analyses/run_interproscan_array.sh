#!/bin/bash
#SBATCH --array=1-57
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=2:00:00
#SBATCH -A OD-234804
#SBATCH --output=./logs/job_%A_%a.out

module load interproscan

INPUT_FILE=$(ls split_fastas/*.faa | sed -n ${SLURM_ARRAY_TASK_ID}p)
OUTPUT_FILE="interpro_results/$(basename ${INPUT_FILE%.faa}).tsv"

# Run InterProScan
interproscan.sh -f tsv -dp -dra --cpu 4 -i ${INPUT_FILE} -o ${OUTPUT_FILE} -goterms
