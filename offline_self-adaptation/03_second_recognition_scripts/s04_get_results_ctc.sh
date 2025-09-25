#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

# Compute WER

SRC=/home/jausanjo/asr-scripts/wer++

RES=results; mkdir -p $RES

for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
do
VMOD=$(echo $MODEL | awk -F'_' '{print $3}')

for TASK in LHCP-2020 LHCP-2022
do
    for SET in dev #test
    do
        for EP in 5
        do

            for HYP in `find out_hyp.$VMOD/$TASK/$SET -name "[0-9]*.ep$EP.txt.post.clean"`
            do
                NAME=$(basename $HYP .txt.post.clean | sed 's|[.]ep.||g')
                REF=ref/${TASK}/${SET}/$NAME.ref
                AUX=$($SRC/wer++.py $HYP $REF 2> /dev/null | grep "WER")
                echo "$NAME.ep$EP $AUX" 
            done
            ALLHYP=out_hyp.$VMOD/${TASK}/${SET}/all.ep$EP.txt.post.clean
            ALLREF=ref/${TASK}/${SET}/all.ref
            AUX=$($SRC/wer++.py $ALLHYP $ALLREF 2> /dev/null | grep "WER")
            echo "=================================================================="
            echo "OVERALL $AUX" 

        done > $RES/res_$VMOD.ep$EP.$TASK.$SET.txt
    done
done

done
