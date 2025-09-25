#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

SRC=/home/jausanjo/asr-scripts/wer++

RES=results; mkdir -p $RES

for TASK in LHCP-2020 LHCP-2022
do
    for SET in dev test
    do
        for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
        do

        VMOD=$(echo $MODEL | awk -F'_' '{print $3}')

        {
        for HYP in `find baseline_out.$VMOD/$TASK/$SET -name "[0-9]*.txt.post.clean" | sort -V`
        do
            NAME=`basename $HYP .txt.post.clean`
            REF=ref/$TASK/$SET/$NAME.ref
            AUX=$($SRC/wer++.py $HYP $REF 2> /dev/null | grep "WER")
            echo $NAME $AUX 
        done 
        ALLHYP=baseline_out.$VMOD/${TASK}/${SET}/all.txt.post.clean
        ALLREF=ref/${TASK}/${SET}/all.ref
        AUX=$($SRC/wer++.py $ALLHYP $ALLREF 2> /dev/null | grep "WER")
        echo "=================================================================="
        echo "OVERALL $AUX" 
        } >> $RES/$TASK.$SET.$VMOD.txt

        done
    done
done
