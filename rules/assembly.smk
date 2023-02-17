rule megahit:
    input:
        bac=rules.prebin.input.prebin_bac
        arch=rules.prebin.input.prebin_arch
        euk=rules.prebin.input.prebin_euk
        unk=rules.prebin.input.prebin_unk
    output:
        bac_out="megahit/bacteria"
        arch_out="megahit/archaea"
        euk_out="megahit/eukaryota"
    resources:
        mem_gb=50
    shell:
        """
        # megahit -r {input.bac},{input.unk} -o {output.bac_out}
        # megahit -r {input.arch},{input.unk} -o {output.arch_out}
        megahit -r {input.euk},{input.unk} -o {output.euk_out}
        """

rule metaspades:
    input:
        bac=rules.prebin.input.prebin_bac
        arch=rules.prebin.input.prebin_arch
        euk=rules.prebin.input.prebin_euk
        unk=rules.prebin.input.prebin_unk
    output:
        bac_out="metaspades/bacteria"
        arch_out="metaspades/archaea"
        euk_out="metaspades/eukaryota"
    resources:
        mem_gb=150
    shell:
        """
        # python3 SPAdes-3.15.5-Linux/bin/spades.py --meta --merged {input.bac},{input.unk} -o {output.bac_out}
        # python3 SPAdes-3.15.5-Linux/bin/spades.py --meta --merged {input.arch},{input.unk} -o {output.arch_out}
        python3 SPAdes-3.15.5-Linux/bin/spades.py --meta --merged {input.euk},{input.unk} -o {output.euk_out}
        """
