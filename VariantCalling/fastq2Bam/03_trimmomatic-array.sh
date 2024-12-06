#!/bin/bash --login
#SBATCH --job-name="fastqc"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1		# use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=20:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o fqc_%A_%a.o          # standard output
#SBATCH -e fqc_%A_%a.e	        # standard erro

module load fastqc/0.11.9-java-11


fastqc --extract /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq_files/* -f fastq -o fastqc_output
[uqzmezie@bunya2 fastq2Bam]$ nano 02_multiqc.sh
[uqzmezie@bunya2 fastq2Bam]$ cat 03_trimmomatic-array.sh 
#!/bin/bash --login
#SBATCH --job-name="trim"       # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1		# number of cores per job
#SBATCH --mem=200G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=20:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH --array=1-237        	# job array
#SBATCH -e trim_%A_%a.e      	# standard error
#SBATCH -o trim_%A_%a.o

# text fille including all fastq file names
LIST=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/fastqList
INDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq_files
OUTDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/fastq_clean

# file name variable is associated ARRAY index
FILENAME=`cat ${LIST} | tail -n +${SLURM_ARRAY_TASK_ID} | head -1`
BASE=`basename ${FILENAME} _1.fq.gz`

module load anaconda3/2022.05
source activate trimmomatic

trimmomatic PE -phred33 ${INDIR}/${BASE}_1.fq.gz ${INDIR}/${BASE}_2.fq.gz \
${OUTDIR}/${BASE}_R1_paired.fastq.gz ${OUTDIR}/${BASE}_R1_unpaired.fastq.gz \
${OUTDIR}/${BASE}_R2_paired.fastq.gz ${OUTDIR}/${BASE}_R2_unpaired.fastq.gz \
ILLUMINACLIP:adapters.txt:2:30:10:4:true SLIDINGWINDOW:4:20 MINLEN:50
