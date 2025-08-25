#!/bin/bash --login
#SBATCH --job-name="beagle4"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=8               # number of cores per job
#SBATCH --mem=500G                               # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=168:00:00                # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o beagle5.2.o    # standard output
#SBATCH -e beagle5.2.e    # standard error

module load java

java -Xmx500g -jar beagle.28Jun21.220.jar gt=Spis_noreplicates_badsamples_filtered_linked.vcf out=beagle5.2_Spis_filtered_linked_imp
