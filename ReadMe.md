This directory riddell26 contains all work done by
James Riddell V (riddell.26@buckeyemail.osu.edu) from
01-2023 to 02-16-2023. Please refer to this ReadMe for
information on the directories, and email me if there are any questions or issues.

# Usage and requirements

This script requires snakemake, fastqc, trimmomatic, bbduk, tiara, megahit, and pandaseq to be installed. Each can be installed with conda.
Kraken2 does not need to be installed since it runs through singularity, but the database needs to be installed: https://github.com/DerrickWood/kraken2/wiki/Manual

# Description of files

```euk_metagenomics_pipeline_slurm.sh``` is the slurm job script that runs ```Snakefile```.

```Snakefile``` contains the snakemake run script for all of the snakemake rules.
To add more rules, use include: <rule>.smk. \
To remove a rule, comment it out and the terminal output files in the rule all.

The snakemake rules are contained in the ```rules``` directory.
```preprocessing.smk``` runs fastqc on raw reads, finds the overrepresented sequences from the raw reads, trims reads with trimmomatic, removes human contamination with bbduk, then another fastqc to quality check.

```prebinning.smk``` merges reads with pandaseq, then taxonomically annotates each read with kraken2. Next, it makes three fasta files of merged reads separated by domain.

```assembly.smk``` assembles prebinned reads with megahit and metaspades.

```tiara.smk``` is also available but is not currently included in the snakefile. To run tiara.smk, simply add include: tiara.smk to the Snakefile and expand its terminal outputs in the rule all.

Before running the slurm script, a directory called ```raw_data``` needs to be created and contain all the all the raw reads you want to run. Snakemake uses this directory to recognize the files

directories rawQC, trimmomatic, bbduk, pandaseq, decontaminatedQC, and kraken2 must also be created before running the slurm script.

GCF_000001405.40_GRCh38.p14_genomic.fna is a human genome reference downloaded from NCBI that is used in bbduk to match sequences to. This needs to be installed from https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.40/
