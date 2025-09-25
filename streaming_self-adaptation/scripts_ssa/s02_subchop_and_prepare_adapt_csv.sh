#!/bin/bash

set -e

export LC_ALL=C.UTF-8

if [[ $# != 4 ]]
then 
    echo "$0 <audio_path> <context_len> <dir_adapt_samples> <dir_csv>"
    exit 1
fi

AUDIO_PATH=$1
CONTEXT_LEN=$2
DIR_ADAPT=$3
DIR_CSV=$4

ODIR=${AUDIO_PATH%.wav}; mkdir -p $ODIR
FNAME=$(basename $(dirname $AUDIO_PATH))
F_T_INI=$(basename $ODIR | awk -F_ '{print $NF}' | awk -F. '{print $1}'  )

F_LEN=$(soxi -D $AUDIO_PATH)
T_SEG=$((30 - 2 * $CONTEXT_LEN))


# First segment!
T_END=$((T_SEG + CONTEXT_LEN))
REAL_T_END=$(echo "$T_END + $F_T_INI" | bc)
FOUT=$(echo "$ODIR/$FNAME $F_T_INI $REAL_T_END" | awk '{printf("%s_%08.2f-%08.2f.wav", $1, $2, $3)}')
if [[ ! -e $FOUT ]]; then
sox $AUDIO_PATH $FOUT trim 0 $T_END
fi

# 1. Chop chunked file into segment-sized subfiles
for T_INI in $(seq $((T_SEG - CONTEXT_LEN)) $T_SEG ${F_LEN%.*})
do 
    if [[ $( echo "$T_INI >= $F_LEN" | bc ) -ne 0 ]]
    then
        continue
    fi

    T_END=$((T_INI + 30))
    REAL_T_INI=$(echo "$T_INI + $F_T_INI" | bc)
    if [[ $( echo "$T_END >= $F_LEN" | bc ) -ne 0 ]]
    then
        # T_END = F_LEN
        REAL_T_END=$(echo "$F_LEN + $F_T_INI" | bc)
        FOUT=$(echo "$ODIR/$FNAME $REAL_T_INI $REAL_T_END" | awk '{printf("%s_%08.2f-%08.2f.wav", $1, $2, $3)}')
        if [[ ! -e $FOUT ]]; then
        sox $AUDIO_PATH $FOUT trim $T_INI
        fi
    else
        # T_END = T_END
        REAL_T_END=$(echo "$T_END + $F_T_INI" | bc)
        FOUT=$(echo "$ODIR/$FNAME $REAL_T_INI $REAL_T_END" | awk '{printf("%s_%08.2f-%08.2f.wav", $1, $2, $3)}')
        if [[ ! -e $FOUT ]]; then
        sox $AUDIO_PATH $FOUT trim $T_INI 30
        fi
    fi
done

# 2. Prepare CSVs to adapt model
ODIRCSV=$DIR_CSV/$FNAME; mkdir -p $ODIRCSV
DIRTXT=$(echo $ODIR | sed 's|'$(echo $ODIR | awk -F/ '{print $1}')'|'$DIR_ADAPT'|g')
BASENM=$(basename $AUDIO_PATH .wav)

SNUM=0
for SEG in $(find $ODIR/ -name '*.wav' | sort -V)
do
    SNUMP=$(printf '%03d' $SNUM)
    if [[ -f $DIRTXT/${BASENM}-$SNUMP.txt ]]
    then
        TXT=$(cat $DIRTXT/${BASENM}-$SNUMP.txt)
        echo "$SEG|$TXT|$TXT"
    fi
    SNUM=$((SNUM+1))
done > $ODIRCSV/$BASENM.csv
