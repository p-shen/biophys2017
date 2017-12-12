#!/bin/bash

#SBATCH -p short   # queue name
#SBATCH -t 0-24:00       # hours:minutes runlimit after which job will be killed.
#SBATCH -n 8      # number of cores requested
#SBATCH --mem=64G # memory requested
#SBATCH -J essential_genes         # Job name
#SBATCH -o %j.out       # File to which standard out will be written
#SBATCH -e %j.err       # File to which standard err will be written
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Peter_Shen@hms.harvard.edu

# make dependencies
module load gcc/6.2.0
module load R/3.4.1

# preprocessing (this won't be necessary everytime, so comment it out)
Rscript preprocessing.R

# this file will be used to run the statistics processing in parallel on the
# essential genes and non-essential genes
