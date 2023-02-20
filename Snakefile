# credit: adapted from Alex Soupir https://www.youtube.com/watch?v=_wUGzqEjg6A
import os
import glob

SAMPLE,FRR = glob_wildcards("raw_data/{sample}_{frr}.fastq.gz")
# for co-assembly we only need the sample number
SAMPLE_NUM = glob_wildcards("raw_data/{sample_num,\d+}[A-Z]+_R[\d].fastq.gz")

include: "rules/preprocessing.smk" # fastqc, trimmomatic, bbduk, fastqc
include: "rules/prebinning.smk" # pandaseq, kraken2, translate kraken2 and prebin
include: "rules/assembly.smk" # megahit, metaspades

rule all:
    input:
        expand("rawQC/{sample}_{frr}_fastqc.{extension}", sample=SAMPLE, frr=FRR, extension=["zip", "html"]),
	expand("decontaminatedQC/{sample}_{frr}um_fastqc.{extension}",sample=SAMPLE, frr=FRR, extension=["zip", "html"]),
	expand("bbduk/{sample}_{frr}m.fastq.gz", sample=SAMPLE, frr=FRR),
	expand("trimmomatic/{sample}_1unpaired.fastq.gz", sample=SAMPLE),
	expand("trimmomatic/{sample}_2unpaired.fastq.gz", sample=SAMPLE),
        expand("kraken2/{sample}-krak.txt", sample=SAMPLE),
        expand("kraken2/{sample}.kreport", sample=SAMPLE),
        expand("prebin/{sample}_bacteria.fasta",sample=SAMPLE),
        expand("prebin/{sample}_archaea.fasta",sample=SAMPLE),
        expand("prebin/{sample}_eukaryota.fasta",sample=SAMPLE),
