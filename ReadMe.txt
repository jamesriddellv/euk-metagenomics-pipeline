This directory riddell26 contains all work done by
James Riddell V (riddell.26@buckeyemail.osu.edu) from
01-2023 to 02-16-2023. Please refer to this ReadMe for
information on the directories, and email me if there are any questions or issues.

/raw_data/ contains all the sequences that go into the snakemake pipeline.
The sequences must be in a folder called /raw_data/ for snakemake to recognize
where the raw files are, or needs to be changed in the Snakefile.

Snakefile is the run script for the snakemake pipeline. 
It calls preprocessing.smk and prebinning.smk.
These steps require a stable snakemake installation and additional packages for running
fastqc, bbduk, pandaseq, and trimmomatic. kraken2 is configured to run through singularity,
but the database directory may still need to be installed and specified.

tiara.smk is also available but
is not currently included in the snakefile. To run tiara.smk, simply add include: tiara.smk
to the Snakefile and expand its terminal outputs in the rule all.

any files labeled *_slurm.sh are slurm job manager bash scripts that allow
for submitting the Snakefile using supercomputing resources.

directories rawQC, trimmomatic, bbduk, pandaseq, decontaminatedQC, and kraken2 
all contain the output of the snakemake pipeline and need to be created in the parent
directory before running.

The rules directory has the .smk snakemake rules broken down into a
preprocessing step, which contains fastqc, trimmomatic, bbduk, and fastqc again,
while the prebinning.smk file has pandaseq and kraken2. The reason these
are broken down that way is because the outputs of the second fastqc step need
to be manually checked for quality before sending through the pandaseq and
kraken2 pipelines.

GCF_000001405.40_GRCh38.p14_genomic.fna is a human genome reference downloaded
from NCBI that is used in bbduk to match sequences to.
This needs to be installed from https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.40/