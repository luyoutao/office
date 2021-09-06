#! /usr/bin/python3

import argparse
from PIL import Image
import os
import time
import shutil
import sys

parser = argparse.ArgumentParser(prog = "rename_exif")
parser.add_argument('--in', type = str, nargs = 1, dest = "dir_in", help = "input directory")
parser.add_argument('--out', type = str, default = ".", nargs = 1, dest = "dir_out", help = "output directory")
args = parser.parse_args()

dir = vars(args)['dir_in'][0]
out = vars(args)['dir_out'][0]
print("input dir:", dir, "  ", "output dir:", out)
if not os.path.exists(dir):
    sys.exit("input directory not exists")
if not os.path.exists(out):
    os.mkdir(out)
    print("creating", out, "...")

def rename_exif(dir):
    if os.path.isdir(dir):
        files = os.listdir(dir)
        for f in files:
            rename_photos(dir + "/" + f)
    else:
        ext = dir.lower().split('.')[-1]
        if ext == "jpg" or ext == "heic" or ext == "heif" or ext == "tif" or ext == "tiff":
            print(dir, end = "")
            img = Image.open(dir)
            exif_data = img._getexif()
            if exif_data is not None:
                exif = exif_data.items()
                dev = [v for (k,v) in exif if k == 271]
                mtime = [v for (k,v) in exif if k == 306]
                if len(dev) and len(mtime):
                    dev = dev[0]
                    mtime = mtime[0]
                    mtime = mtime.replace(":", "-")
                    new_name =  out + "/" + dev + " " + mtime + "." + ext                
                else:
                    new_name = out + "/" + os.path.basename(dir)
            else:
                mtime = os.path.getmtime(dir)
                localtime = time.localtime(mtime)
                y = str(localtime[0])
                mon = str(localtime[1]) if len(str(localtime[1])) > 1 else "0" + str(localtime[1])
                d = str(localtime[2]) if len(str(localtime[2])) > 1 else "0" + str(localtime[2])
                h = str(localtime[3]) if len(str(localtime[3])) > 1 else "0" + str(localtime[3])
                m = str(localtime[4]) if len(str(localtime[4])) > 1 else "0" + str(localtime[4])
                s = str(localtime[5]) if len(str(localtime[5])) > 1 else "0" + str(localtime[5])
                new_name =  out + "/" + "Unknown" + " " + "-".join([y, mon, d]) + " " + "-".join([h, m, s]) + "." + ext
            print("-> " + new_name, end = "")
            if new_name != "":
                shutil.copy2(dir, new_name)
            else:
                print("-> failed!", end = "")
            print("")

if __name__ == "__main__":
    rename_exif(dir)
    
