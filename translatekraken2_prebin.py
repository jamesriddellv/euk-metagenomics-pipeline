#translates NCBI taxids in default kraken2 output to names in 'mpa' style using Taxonkit
#modified by James Riddell (riddell.26@buckeyemail.osu.edu) to output only the sequence headers separated into three files based on the taxonomic domain of the sequence assigned by kraken2
from argparse import ArgumentParser
import subprocess

#get the default kraken2 output and the file to save translated names file to
parser = ArgumentParser()
parser.add_argument("--infile",dest="infile", help="Kraken output file to be translated: <sample>-krak.txt")
args = parser.parse_args()

#open the files
infile = open(args.infile, 'r')
sample = args.infile.split('-krak.txt')[0]
bac_outfile = open(sample + '-krak-bacteria.txt', 'w')
arch_outfile = open(sample + '-krak-archaea.txt', 'w')
euk_outfile = open(sample + '-krak-eukaryota.txt', 'w')

#read name to taxid mapping
readnames=[]
taxids=[]

#unique taxids to find the taxonomic names for
uniqueids=[]

#go through each kraken result and get taxids
for i in infile:
    row = i.split("\t")
    readname = row[1]
    taxid = row[2]
    readnames.append(readname)
    taxids.append(taxid)
    if taxid not in uniqueids:
        uniqueids.append(taxid)

#dictionary to store found ids
bac_taxdic={}
arch_taxdic={}
euk_taxdic={}

#get the full lineage names for unique taxids using Taxonkit
taxonkit = subprocess.check_output("echo '{}' | taxonkit lineage | taxonkit reformat".format("\n".join(uniqueids)), shell=True)
taxonkit=taxonkit.decode().split("\n")

#taxonomic levels
levs=["d__","p__","c__","o__","f__","g__","s__"]

#function to generate the mpa name from a given taxid by calling Taxonkit
def formName(name):
    names = name.split(";")
    formnames = []
    for i in range(len(names)):
        if names[i] != "":
            formnames.append(levs[i]+names[i].replace(" ","_"))
    return("|".join(formnames))

#reformat to mpa style
for i in taxonkit:
    if i != "":
        row=i.split("\t")
        tid=row[0]
        mpaname=formName(row[2])
        if 'd__Bacteria' in mpaname:
            bac_taxdic[tid] = mpaname
        elif 'd__Archaea' in mpaname:
            arch_taxdic[tid] = mpaname
        elif 'd__Eukaryota' in mpaname:
            euk_taxdic[tid] = mpaname

#write the translated read to taxname file
for i in range(len(readnames)):
    t=taxids[i]
    if t in bac_taxdic:
        bac_outfile.write("{}\n".format(readnames[i]))
    elif t in arch_taxdic:
        arch_outfile.write("{}\n".format(readnames[i]))
    elif t in euk_taxdic:
        euk_outfile.write("{}\n".format(readnames[i]))
bac_outfile.close()
arch_outfile.close()
euk_outfile.close()
