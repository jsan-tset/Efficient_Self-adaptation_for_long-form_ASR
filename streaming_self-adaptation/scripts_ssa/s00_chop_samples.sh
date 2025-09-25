#!/bin/bash

set -e

export LC_ALL=C.UTF-8

if [[ $# != 6 ]]
then 
    echo "$0 <FILE> <CHUNK_SIZE> <CONTEXT_L> <CONTEXT_R> <ODIR> <DIR_LST>"
    echo "FILE: path to file. Format: path/<TASK>/<SET>/<FILE>.wav"
    echo "CHUNK_SIZE: chunk size (time, in seconds)"
    echo "CONTEXT_L: left context, (time, in seconds)"
    echo "CONTEXT_R: right context, (time, in seconds)"
    echo "ODIR: name of the output directory. Files will be created in ODIR/<TASK>/<SET>/<FILE>/here"
    echo "DIR_LST: lists directory"
    exit 1
fi

FILE=$1
CHUNK_SIZE=$2
CONTEXT_L=$3
CONTEXT_R=$4
NAME_ODIR=$5
DIR_LST=$6

ODIR=$(echo $FILE | awk -F/ '{print "'$NAME_ODIR'/"$(NF-2)"/"$(NF-1)"/"substr($NF, 0, length($NF)-4)}')
mkdir -p $ODIR

# Chop file into chunk-sized subfiles
F_LEN=$(soxi -D $FILE)
FNAME=$(basename $FILE .wav)
for T_INI in $(seq 0 $CHUNK_SIZE ${F_LEN%.*})
do
    T_END=$(($T_INI + $CHUNK_SIZE + $CONTEXT_R))
    SOXEND=$((CHUNK_SIZE + CONTEXT_R))

    if [[ $T_INI -ne 0 ]]
    then
        T_INI=$(($T_INI - $CONTEXT_L))
        SOXEND=$((SOXEND + CONTEXT_L))
    fi

    if [[ $(echo "$T_END > $F_LEN" | bc) -ne 0 ]]
    then
        FOUT=$(echo "$ODIR/$FNAME $T_INI $F_LEN" | awk '{printf("%s_%08.2f-%08.2f.wav", $1, $2, $3)}')
        if [[ ! -e $FOUT ]]; then
        sox $FILE $FOUT trim $T_INI
        fi
    else
        FOUT=$(echo "$ODIR/$FNAME $T_INI $T_END" | awk '{printf("%s_%08.2f-%08.2f.wav", $1, $2, $3)}')
        if [[ ! -e $FOUT ]]; then
        sox $FILE $FOUT trim $T_INI $SOXEND
        fi
    fi
done
OLIST=$DIR_LST/$FNAME; mkdir -p $OLIST
find $ODIR -maxdepth 1 -name '*'$FNAME'*.wav' | sort -V > $OLIST/${FNAME}_chunked_audios.lst
