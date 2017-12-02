### To start a session:
`srun -p interactive --pty --mem 8000 -t 0-12:00 /bin/bash`

### To load Rscript on O2, use:

`module load gcc/6.2.0`
`module load R/3.4.1`

### To run a Rscript, use:

`Rscript scriptname.R`

### To run the preprocessing as a batch job
`sbatch -p short -n 4 -t 0-12:00 --mem=32G --job-name preprocessing -o %j.out -e %j.err --wrap="sh slurm.sh"``

#### To submit a job via sbatch for analysis
`sbatch gene_stat_analysis.sbatch`

### To version your own R packages on O2
https://wiki.rc.hms.harvard.edu/display/O2/Personal+R+Packages

mkdir -p ~/R-VersionSelected/library
echo 'R_LIBS_USER="~/R-VersionSelected/library"' >  $HOME/.Renviron
export R_LIBS_USER="/home/user123/R-VersionSelected/library"

Then you can do `> R` to enter the interactive console and install any packages.
