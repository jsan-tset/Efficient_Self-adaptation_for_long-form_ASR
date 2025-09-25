#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

SCR=~/asr-scripts/asr-scripts/lm/prepro


if [[ $# != 3 ]]
then
    echo "$0 <HYP> <REF> <outdir>" >&2
    exit 1
fi

TXT=$1
REF=$2
ODIR=$3; mkdir -p $ODIR

TMP=$TXT
source /home/jausanjo/pyth_envs/prepro/bin/activate
cat $TXT | $SCR/prepro_am.sh en > $TXT.post
deactivate

HYP=$TXT.post.clean
sed 's/<oov>//g' $TXT.post > $HYP

SRC=/home/jausanjo/asr-scripts/wer++

NAME=`basename $TXT .txt`
AUX=$($SRC/wer++.py $HYP $REF 2> /dev/null | grep "WER")
echo "$NAME $AUX" > $ODIR/res_$NAME.txt
