#! /bin/bash

# load Rscript modules
module load gcc/6.2.0
module load R/3.4.1

# preprocessing -- essential and non-essential gene column ids
Rscript preprocessing.R

# sbatch gene_stat_analysis.sh
sleep 1 # wait 1 second between each job submission
