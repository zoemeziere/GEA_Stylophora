module load samtools/1.13-gcc-10.3.0

# get read groups
for FILENAME in *markedRG.bam; do
samtools view -H ${FILENAME} | grep '^@RG' >> RGList
done

# get sample names
cut -f5 RGList > RGList_SM
sed 's/SM://g' RGList_SM > sampleNames
ls *.bam > bamNames
paste sampleNames bamNames > sampleMap

# OR read from a bamList
#module load samtools/1.13-gcc-10.3.0
#INDIR=/scratch/project/rrap_ahya/analysis/bwa/markedRG_bamUSE
#cat bamsList | while read FILENAME; do
#samtools view -H ${INDIR}/${FILENAME} | grep '^@RG' >> RGList
#done

#cut -f5 RGList > RGList_SM
#sed 's/SM://g' RGList_SM > sampleNames
#paste sampleNames bamList > sampleMap
#sed -i 's/_markedRG.bam/.g.vcf.gz/g' sampleMap

# You can also add path directly to sampleMap file if your input files are not in the same directory

# example sample map file
#Ahya-21550-12	RRAP-ECT01-2021-Ahya-21550-12_L3.g.vcf.gz
#Ahya-B17	RRAP-ECT01-2021-Ahya-B17_L3.g.vcf.gz
#Ahya-B18	RRAP-ECT01-2021-Ahya-B18_L3.g.vcf.gz
#Ahya-B22	RRAP-ECT01-2021-Ahya-B22_L3.g.vcf.gz
#Ahya-B33	RRAP-ECT01-2021-Ahya-B33_L3.g.vcf.gz
#Ahya-B34	RRAP-ECT01-2021-Ahya-B34_L3.g.vcf.gz

# create interval_list file
#sed -i 's/\t/:/g' genomic.bed
#sed 's/:0:/:1-/g' genomic.bed > intervals.list
