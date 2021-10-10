import os
import sys
import shutil
import gzip
import argparse
import re

DEBUG = False
VERSION = 0.1

def parseArgs():
    parser = argparse.ArgumentParser(description = "Traverse a directory, look for text files and compress them if they exceed size threshold")
    parser.add_argument("--inDir", metavar = ".", dest = "inDir", type = str, required = False, default = ".", help = "Directory to traverse")
    parser.add_argument("--size", metavar = "4KB", dest = "size", type = str, required = False, default = "4K", help = "Byte beyond which a file gets compressed")
    parser.add_argument("--extensions", metavar = ".txt;[.csv;...]", dest = "extensions", type = str, required = False, default = ".txt;.csv;.tsv;.fa;.fq;.fasta;.fastq;.bed;.bed12;.bedpe;.narrowPeak;.broadPeak;.gtf;.gff;.gff2;.gff3;.wig;.wiggle;.bedGraph", help = "Formats to be compressed")
    args = parser.parse_args()
    return args

def main():
    args = parseArgs()
    inDir, size, extensions = args.inDir, args.size, args.extensions
    exts = extensions.split(';')
    exts = [x.upper() for x in exts]
    res = re.match(r"(?P<s>\d+)[K|M|G]", size, flags = re.IGNORECASE)
    s = int(res.group('s'))
    if size[-1] == 'k' or size[-1] == 'K':
        s = 1024 * s
    elif size[-1] == 'm' or size[-1] == 'M':
        s = 1024 * 1024 * s
    elif size[-1] == 'g' or size[-1] == 'G':
        s = 1024 * 1024 * 1024 * s

    for root, dirs, files in os.walk(inDir):
        for f in files:
            _, ext = os.path.splitext(f);
            if ext.upper() in exts:
                path = os.path.join(root, f)
                size = os.path.getsize(path)
                if size > s:
                    newpath = path + ".gz"
                    print(path, "gzipped", end = ", ")
                    with open(path, "rb") as inFh:
                        with gzip.open(newpath, "wb") as outFh:
                            shutil.copyfileobj(inFh, outFh)
                    print("removing original file...")
                    os.remove(path)
                    
if __name__ == "__main__":
    main()
