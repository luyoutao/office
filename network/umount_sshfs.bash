#!/bin/bash
# v0.2
# 2020-10-09
fs=("home" "lab" "kimdata")
verbose=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            verbose=true
            shift
            ;;
        --fs)
            shift
            fs=("$@")
            break
            ;;
        *)
            echo "$0 umount_sshfs.bash [--verbose] [--fs home lab kimdata]"
            return 1
            ;;
    esac
done

for x in ${fs[@]}; do
    if [[ $verbose == "true" ]]; then
        echo "sudo diskutil umount force /$x"
    fi
    sudo diskutil umount force /$x
done

