#!/bin/bash
# v0.2
# 2020-10-09

precatalina=false
fs=("home" "lab" "kimdata")
verbose=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --usrname)
            usrname="$2"
            shift; shift
            ;;
        --hostname)
            hostname="$2"
            shift; shift
            ;;
        --uid)
            uid="$2"
            shift; shift
            ;;
        --gid)
            gid="$2"
            shift; shift
            ;;
        --precatalina)
            precatalina=true
            shift
            ;;
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
            echo "$0 mount_sshfs.bash --usrname USER --hostname SERVER --uid UID --gid GID [--precatalina] [--verbose] [--fs home lab kimdata]"
            return 1
            ;;
    esac
done

if [[ $precatalina == "true" ]]; then 
    for x in ${fs[@]}; do
        if [[ $verbose == "true" ]]; then
            echo sudo chown $(whoami) /$x
            echo sudo chmod u+w /$x
            # cache and compression are good to be enabled, so that disconnections happen much less frequently. 
            echo sshfs -o uid=$uid -o gid=$gid -o allow_other -o auto_cache -o cache=yes -o compression=yes -o reconnect -o follow_symlinks -o transform_symlinks -o async_read -o workaround=rename -o workaround=buflimit -o workaround=fstat -o volname=$x $usrname@$hostname:/$x /$x
        fi
        sudo chown $(whoami) /$x
        sudo chmod u+w /$x
        # cache and compression are good to be enabled, so that disconnections happen much less frequently. 
        sshfs -o uid=$uid -o gid=$gid -o allow_other -o auto_cache -o cache=yes -o compression=yes -o reconnect -o follow_symlinks -o transform_symlinks -o async_read -o workaround=rename -o workaround=buflimit -o workaround=fstat -o volname=$x $usrname@$hostname:/$x /$x
    done
else
    for x in ${fs[@]}; do
        if [[ $verbose == "true" ]]; then
            echo sudo chown $(whoami) /System/Volumes/Data/$x
            echo sudo chmod u+w /System/Volumes/Data/$x
            # cache and compression are good to be enabled, so that disconnections happen much less frequently. 
            echo sshfs -o uid=$uid -o gid=$gid -o allow_other -o auto_cache -o cache=yes -o compression=yes -o reconnect -o follow_symlinks -o transform_symlinks -o async_read -o workaround=rename -o workaround=buflimit -o workaround=fstat -o volname=$x $usrname@$hostname:/$x /$x
        fi
        sudo chown $(whoami) /System/Volumes/Data/$x
        sudo chmod u+w /System/Volumes/Data/$x
        # cache and compression are good to be enabled, so that disconnections happen much less frequently. 
        sshfs -o uid=$uid -o gid=$gid -o allow_other -o auto_cache -o cache=yes -o compression=yes -o reconnect -o follow_symlinks -o transform_symlinks -o async_read -o workaround=rename -o workaround=buflimit -o workaround=fstat -o volname=$x $usrname@$hostname:/$x /$x
    done
fi    
