#!/bin/bash
#SBATCH -p owners

module load samtools/1.13-gcc-10.3.0

# get read groups
#for FILENAME in /scratch/project_mnt/S0078/WGS_Stylophora_all/fastq2Bam/markedRG_bamUSE/*markedRG.bam; do
#samtools view -H ${FILENAME} | grep '^@RG' >> RGList
#done

# get sample names
#cut -f5 RGList > RGList_SM
#sed 's/SM://g' RGList_SM > sampleNames

# get path to bam files
#ls /scratch/project_mnt/S0078/WGS_Stylophora_all/fastq2Bam/markedRG_bamUSE/*markedRG.bam > bamNames

# create sample map file
#paste sampleNames bamNames > sampleMap

#sed -i 's/_markedRG.bam/.g.vcf.gz/g' sampleMap
#sed 's/ \+//g' sampleMap
sed 's!/scratch/project_mnt/S0078/WGS_Stylophora_all/fastq2Bam/markedRG_bamUSE/!!g' sampleMap

