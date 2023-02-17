rule pandaseq:
    input:
        forward=rules.bbduk.output.R1_unmatched,
        rev=rules.bbduk.output.R2_unmatched,
    output:
        merged="pandaseq/{sample}_merged.fasta",
    shell:
        """
        pandaseq -f {input.forward} -r {input.rev} -w {output.merged}
        """

rule kraken2:
    input:
        reads=rules.pandaseq.output.merged,
    output:
        krak="kraken2/{sample}-krak.txt",
        krak_report="kraken2/{sample}.kreport",
        unclassified_out = "kraken2/{sample}_unclassified.txt",
    params:
        db = "/fs/ess/PAS1802/Audra/Library/kraken-db7",
    resources:
        mem_gb=100,
    singularity: "docker://quay.io/biocontainers/kraken2:2.1.2--pl5262h7d875b9_0"
    shell: 
        """
        kraken2 \
--report-zero-counts \
--unclassified-out {output.unclassified_out} \
--report {output.krak_report} \
--db {params.db} \
{input.reads} \
--output {output.krak}
        """

rule sep_headers:
    input:
        krak_tax=rules.kraken2.output.krak,
        unk_tax="kraken2/{sample}_unclassified.txt"
    output:
        bac_headers="kraken2/{sample}-krak-bacteria.txt",
        arch_headers="kraken2/{sample}-krak-archaea.txt",
        euk_headers="kraken2/{sample}-krak-eukaryota.txt",
        unk_headers="kraken2/{sample}-krak-unclassified.txt"
    shell:
        """
        ### create list of bac, euk, and arch read headers ###
        python3 translatekraken2_prebin.py --infile {input.krak_tax}

        # get unclassified headers
        grep ">" {input.unk_tax} | sed 's/^>//' > {output.unk_headers}
        """
rule prebin:
    input:
        bac=rules.sep_headers.output.bac_headers,
        arch=rules.sep_headers.output.arch_headers,
        euk=rules.sep_headers.output.euk_headers,
        unk=rules.sep_headers.output.unk_headers,
    output:
        prebin_bac="prebin/{sample}_bacteria.fasta",
        prebin_arch="prebin/{sample}_archaea.fasta",
        prebin_euk="prebin/{sample}_eukaryota.fasta",
        prebin_unk="prebin/{sample}_unclassified.fasta",
    params:
        merged_reads=rules.pandaseq.output.merged
    shell:
        """
        ### split pandaseq merged fasta by assigned taxonomic domain ###
        # must have the seqkit package installed: conda install -c bioconda seqkit
        seqkit grep -n -f {input.bac} {params.merged_reads} > {output.prebin_bac}
        seqkit grep -n -f {input.arch} {params.merged_reads} > {output.prebin_arch}
        seqkit grep -n -f {input.euk} {params.merged_reads} > {output.prebin_euk}
        seqkit grep -n -f {input.unk} {params.merged_reads} > {output.prebin_unk}
        """
