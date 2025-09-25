#!/bin/bash

set -e

export LC_ALL=C.UTF-8

if [[ $# != 4 ]]
then
    echo "$0 <srt> <wav> <out_dir> <path2csv>"
    exit 1
fi

SRT=$1
WAV=$2
OUTD=$3
CSV=$4

mkdir -p $OUTD

python3 scripts/srt_info.py $SRT |
    while read ind start end txt
    do
        DST=$OUTD/$ind.wav
        sox $WAV $DST trim $start =${end} > /dev/null
        echo "$(readlink -f $DST)|$txt|$txt"
    done > $CSV
