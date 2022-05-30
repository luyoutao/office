#!/usr/bin/env bash
## VERSION 0.3
verbose="false"
dimmin=1200
ext="png"
ncores=1

function resize {
    old=$1
    indir=$2
    outdir=$3
    dimmin=$4
    verbose=$5
    IFS=$'\n'
    old=$(basename $old)
    new=$(echo $old | tr ' ' '_').new
    cp $indir/"$old" $outdir/$new
    if [[ $verbose == "true" ]]; then
        echo $indir/$old "->" $outdir/$old
    fi
    if [[ $(identify -format "%[fx:w<h?1:0]" "$outdir/$new") -eq 1 ]]; then 
       convert $outdir/$new -resize ${dimmin}x $outdir/.$new.tmp
    else 
       convert $outdir/$new -resize x${dimmin} $outdir/.$new.tmp
    fi
    mv $outdir/.$new.tmp $outdir/"$old"
    rm $outdir/$new
}
export -f resize
while [[ $# -gt 0 ]]; do 
    case $1 in 
        --in)
            indir=$2
            shift; shift
            ;;
        --out)
            outdir=$2
            shift; shift
            ;;
        --dimmin)
            dimmin=$2
            shift; shift
            ;;
        --ext)
            ext=$2
            shift; shift
            ;;
        --ncores)
            ncores=$2
            shift; shift
            ;;
        --verbose)
            verbose="true"
            shift
            ;;
        *)
            echo $0 resize_image.bash --in indir --out outdir [--ext png] [--dimmin 1200] [--ncores 1] [--verbose] 
            exit 1
            ;;
    esac
done
mkdir -p $outdir
if [[ $ncores -eq 1 ]]; then
    ls $indir/*.$ext | sed 's/  /\n/' | while read -r old; do resize $old $indir $outdir $dimmin $verbose; done
else
    ls $indir/*.$ext | sed 's/  /\n/' | parallel -j $ncores -k "resize {1} $indir $outdir $dimmin $verbose"
fi
