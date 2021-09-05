#!/usr/bin/env python3
# depends on ImageMagick

import tempfile
import argparse
import subprocess
import glob
import pathlib
import os
import sys
import shutil 
import zipfile
# replaced by system call due to some issues with this module on Windows
# from wand.image import Image 
DEBUG = False
VERSION = 0.4

def parseArgs():
    parser = argparse.ArgumentParser(description = "Losslessly compress TIFF/PNG/GIF/BMP images in a PPTX, DOCX or XLSX to reduce file size")
    parser.add_argument('--inFile', metavar = "input.(pptx|docx|xlsx)", dest = 'inFile', required = True, help = "input file")
    parser.add_argument('--outFile', metavar = "output.(pptx|docx|xlsx)", dest = 'outFile', required = False, help = "output file. If missing, will backup --inFile to a new file with the suffix specified by --bakSuffix, then REPLACE it with the compressed version")
    parser.add_argument('--bakSuffix', metavar = ".bak", dest = 'bakSuffix', default = ".bak", required = False, help = "suffix of the backup file (default '.bak') if --outFile is missing")
    parser.add_argument('--compress', metavar = "lzw|zip", dest = 'compress', default = "lzw", choices = ['lzw', 'zip'], required = False, help = "lossless compression algorithm, choose from 'lzw' or 'zip' (default: lzw)")
    args = parser.parse_args()
    return args

def getFileType(filename):
    Map = { ".PPTX" : "ppt", ".DOCX" : "word", ".XLSX" : "xl" }
    suffix = pathlib.Path(filename).suffix.upper()
    fileType = Map[suffix]
    return fileType

def compressImages(inDir, fileType, fmts = ('tif', 'tiff', 'png', 'gif', 'bmp'), compress = 'lzw'):
    files = { fmt : glob.glob(os.path.join(inDir, fileType, "media", "*." + fmt)) for fmt in fmts }
    for fmt in fmts:
        fs = files[fmt]
        if len(fs) > 0:
            for fin in fs:
                ftmp = os.path.join(os.path.dirname(fin), pathlib.Path(fin).stem + '.tmp')
                fail = False
                print("Compressing", fin, "and saving it to", ftmp, "...")
                try:
                    ret = subprocess.call(["convert", "-compress", compress, fin, ftmp])
                    if ret != 0:
                        print("Child returns nonzero code:", ret, file = sys.stderr)
                        fail = True
                        pass
                    else:
                        if DEBUG:
                            print("Child returns:", ret, file = sys.stderr)
                except OSError as e:
                    print("Execution faied:", e, file = sys.stderr)
                    fail = True
                    pass
                if not fail:
                    size0 = os.stat(fin).st_size
                    size1 = os.stat(ftmp).st_size
                    if (size1 < size0):
                        os.rename(ftmp, fin)
                    else:
                        print("After compression", fin, "becomes bigger! Skipping this file...", file = sys.stderr)
                        os.remove(ftmp)

def decompressOOXML(inFile, outDir):
    with zipfile.ZipFile(inFile, 'r') as fh:
        fh.extractall(outDir)

def compressOOXML(inDir, outFile):
    fh = zipfile.ZipFile(outFile, 'w', zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk(inDir):
        for file in files:
            path = os.path.join(root, file)
            relPath = pathlib.Path(path).relative_to(inDir)
            fh.write(path, arcname = relPath)
    fh.close()

def createTmpDir():
    dirName = tempfile.TemporaryDirectory()
    return dirName

def main():
    args = parseArgs()
    inFile, outFile, compress = args.inFile, args.outFile, args.compress
    fileType = getFileType(inFile)
    if outFile == None:
        bakSuffix = args.bakSuffix
        bakFile = inFile + bakSuffix
        shutil.copy(inFile, bakFile)
        inFile, outFile = bakFile, inFile
    tmpDir = createTmpDir()
    decompressOOXML(inFile, tmpDir.name)
    compressImages(tmpDir.name, fileType, compress = compress)
    compressOOXML(tmpDir.name, outFile)
    tmpDir.cleanup()

if __name__ == '__main__':
    main()
