rule tiara:
    input:
        assembly="{sample}_assembly",
    output:
        tiara_outfile="tiara/{sample}_tiara.txt",
    shell:
        """
        tiara -i {assembly} -m 1000 --to_fasta euk unk -o {outfile} -t 28
        """
