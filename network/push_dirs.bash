#! /usr/bin/env bash
Dirs=("Workspace")
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
        --dirs)
            shift
            Dirs=("$@")
            break
            ;;
        *)
            echo "$0 push_dirs.bash --usrname USER --hostname SERVER [--dirs Workspace ...]"
            return 1
            ;;
    esac
done

if [[ -z $usrname ]]; then
    echo "missing --usrname!"
    exit 1
fi

if [[ -z $hostname ]]; then
    echo "missing --hostname!"
    exit 1
fi

declare -A LogFiles
mkdir -p $HOME/Log
for dir in ${Dirs[@]}; do
    timestamp=$(date '+%Y%m%d%H%M%S%z')
    LogFiles[$dir]=$HOME/Log/push_${dir}_${timestamp}.log
    rsync -avh --stats --delete --exclude=.cache --exclude=".~*" --exclude="._*" --exclude="~\$*" --exclude=".DS_Store" --exclude=".RDataTmp" $HOME/$dir $usrname@$hostname://home/$usrname/ | tee ${LogFiles[$dir]} 2>&1 
    echo "---------------------------------------------------------------------------------" >> ${LogFiles[$dir]}
done
echo "Scheduled push (local-to-remote) ${Dirs[@]} to $hostname finished at $(date '+%Y-%m-%d %H:%M:%S %z')"
notify_email.pl --subject "Scheduled push (local-to-remote) ${Dirs[@]} to $hostname finished at $(date '+%Y-%m-%d %H:%M:%S %z')" --bodyFile $(echo ${LogFiles[*]} | tr " " ",")
