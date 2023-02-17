rule fastqc:
    input:
        rawread="raw_data/{sample}_{frr}.fastq.gz"
    output:
        zip="rawQC/{sample}_{frr}_fastqc.zip",
        html="rawQC/{sample}_{frr}_fastqc.html",
    threads:
        1
    params:
        path="rawQC/"
    resources:
        mem_gb=50
    shell:
        """
        fastqc {input.rawread} --threads {threads} -o {params.path}
        """
		
rule generate_illuminaclip:
    input:
        R1="rawQC/{sample}_R1_fastqc.zip",
        R2="rawQC/{sample}_R2_fastqc.zip",
    output:
        illuminaclip="rawQC/{sample}_Repseq.fa",
    params:
        R1_dir="rawQC/{sample}_R1_fastqc",
        R2_dir="rawQC/{sample}_R2_fastqc",
        R1_overrep_seqs="rawQC/{sample}_R1_overrepresented_sequences.txt",
        R2_overrep_seqs="rawQC/{sample}_R2_overrepresented_sequences.txt",
        R1_overrep_fasta="rawQC/{sample}_R1_overrepresented_sequences.fa",
        R2_overrep_fasta="rawQC/{sample}_R2_overrepresented_sequences.fa",
        concat_fasta="rawQC/{sample}_Repseq.fa",
    resources:
        mem_gb=50
    shell:
        """
        # generate illuminaclip from fastqc
        unzip -o {input.R1} -d rawQC/
        unzip -o {input.R2} -d rawQC/

        # R1 #
        # extract overrepresented sequences
        awk '/>>Overrepresented sequences/,/>>END_MODULE/' '{params.R1_dir}/fastqc_data.txt' | sed 's/|/ /' | awk '{{print $1}}' | sed '1d;2d;$d' > {params.R1_overrep_seqs}
			
        # Write into fasta file format
        cat {params.R1_overrep_seqs} | while read line; do printf ">\n${{line}}\n"; done > {params.R1_overrep_fasta}

        # R2 #
        # extract overrepresented sequences
        awk '/>>Overrepresented sequences/,/>>END_MODULE/' "{params.R2_dir}/fastqc_data.txt" | sed 's/|/ /' | awk '{{print $1}}' | sed '1d;2d;$d' > {params.R2_overrep_seqs}
		
        # Write into fasta file format
        cat {params.R2_overrep_seqs} | while read line; do printf ">\n${{line}}\n"; done > {params.R2_overrep_fasta}

        # concatenate R1 and R2
        cat {params.R1_overrep_fasta} {params.R2_overrep_fasta} > {output.illuminaclip}
        """			
	
rule trimmomatic:
    input:
        R1="raw_data/{sample}_R1.fastq.gz",
        R2="raw_data/{sample}_R2.fastq.gz",
        illuminaclip={rules.generate_illuminaclip.output.illuminaclip},
    output:
        R1_paired="trimmomatic/{sample}_1paired.fastq.gz",
        R1_unpaired="trimmomatic/{sample}_1unpaired.fastq.gz",
        R2_paired="trimmomatic/{sample}_2paired.fastq.gz",
        R2_unpaired="trimmomatic/{sample}_2unpaired.fastq.gz",
    threads:
        16
    resources:
        mem_gb=50
    params:
        log="trimmomatic/{sample}.log"
    shell:
        """
        module load trimmomatic
        java -jar $TRIMMOMATIC PE -phred33 -threads {threads} {input.R1} {input.R2} {output.R1_paired} {output.R1_unpaired} {output.R2_paired} {output.R2_unpaired} ILLUMINACLIP:{input.illuminaclip}:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 HEADCROP:15 MINLEN:50 2>{params.log}
        """

rule bbduk:
    input:
        R1=rules.trimmomatic.output.R1_paired,
        R2=rules.trimmomatic.output.R2_paired,
        ref="/fs/ess/PAS1802/riddell26/GCF_000001405.40_GRCh38.p14_genomic.fna",
    output:
        R1_unmatched="bbduk/{sample}_R1um.fastq.gz",
        R2_unmatched="bbduk/{sample}_R2um.fastq.gz",
        R1_matched="bbduk/{sample}_R1m.fastq.gz",
        R2_matched="bbduk/{sample}_R2m.fastq.gz",
        stats="bbduk/{sample}-stats.txt",
    resources:
        mem_gb=150,
    shell:
        """
	/fs/ess/PAS1802/Audra/e-Micro_Apps/bbmap/bbduk.sh -Xmx128g in1={input.R1} in2={input.R2} out1={output.R1_unmatched} out2={output.R2_unmatched} outm1={output.R1_matched} outm2={output.R2_matched} ref={input.ref} k=31 stats={output.stats}
	"""
		
rule fastqc2: # run fastqc on the bbduk unmatched outputs
    input:
        rawread="bbduk/{sample}_{frr}um.fastq.gz"
    output:
        zip="decontaminatedQC/{sample}_{frr}um_fastqc.zip",
        html="decontaminatedQC/{sample}_{frr}um_fastqc.html"
    threads:
        1
    params:
        path="decontaminatedQC/"
    resources:
        mem_gb=50
    shell:
        """
        fastqc {input.rawread} --threads {threads} -o {params.path}
        """

# rule pandaseq:
#     input:
#         forward=rules.bbduk.output.R1_unmatched,
#         rev=rules.bbduk.output.R2_unmatched,
#     output:
#         merged="pandaseq/{sample}_merged.fasta",
#     shell:
#         """
#         pandaseq -f {input.forward} -r {input.rev} -w {output.merged}
#         """
