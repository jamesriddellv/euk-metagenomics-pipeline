#!/bin/bash
#SBATCH --time=8:00:00
#SBATCH --nodes=1
#SBATCH --mem=177gb
#SBATCH --account=PAS1802
#SBATCH --job-name=snakemake
#SBATCH --mail-user=riddell.26@buckeyemail.osu.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --export=ALL
### activate snakemake environment ###
# conda activate mamba
# mamba activate snakemake

module load fastqc
module load trimmomatic

snakemake -s Snakefile --use-singularity --cores all --rerun-incomplete --resources mem_gb=177
