
#!/bin/bash
# Usage: ./run_interproscan.sh <input_fasta>

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_fasta>"
    exit 1
fi

module load seqkit
module load interproscan

INPUT_FASTA=$1
SPLIT_DIR="split_fastas"
RESULTS_DIR="interpro_results"
FINAL_OUTPUT="${INPUT_FASTA%.faa}.InterProScan.tsv"

# Create directories
mkdir -p $SPLIT_DIR $RESULTS_DIR

# Split the fasta file into chunks of 500 sequences
seqkit split -s 500 $INPUT_FASTA -O $SPLIT_DIR

# Calculate the number of split files
N_ARRAYS=$(ls ${SPLIT_DIR}/*.faa | wc -l)

# Create the SLURM job array script
cat << EOF > run_interproscan_array.sh
#!/bin/bash
#SBATCH --array=1-${N_ARRAYS}
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=2:00:00
#SBATCH -A OD-234804
#SBATCH --output=./logs/job_%A_%a.out

module load interproscan

INPUT_FILE=\$(ls ${SPLIT_DIR}/*.faa | sed -n \${SLURM_ARRAY_TASK_ID}p)
OUTPUT_FILE="${RESULTS_DIR}/\$(basename \${INPUT_FILE%.faa}).tsv"

# Run InterProScan
interproscan.sh -f tsv -dp -dra --cpu 4 -i \${INPUT_FILE} -o \${OUTPUT_FILE} -goterms
EOF

# Submit the array job
JOB_ID=$(sbatch --parsable run_interproscan_array.sh)

echo "Done"
 
