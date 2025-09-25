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
SET=test


for LR in 0.003 
do

cat <<EOF |
4 8
8 16
16 32
32 64
64 128
128 256
EOF
while read RANK ALPHA
do


for EP in 2 #{1..5}
do
{
cat lists/samples_${TASK}_${SET}.lst |
    while read SPL
    do

    HYP=out_hyp.$VMOD/lr$LR.r$RANK.a$ALPHA/$TASK/$SET/$SPL.ep$EP.txt.post.clean
    REF=ref/$TASK/$SET/$SPL.ref
    AUX=$($SRC/wer++.py $HYP $REF 2> /dev/null | grep "WER")
    echo "$SPL $AUX" 

    done 
ALLHYP=out_hyp.$VMOD/lr$LR.r$RANK.a$ALPHA/$TASK/$SET/all.ep$EP.txt.post.clean
ALLREF=ref/${TASK}/${SET}/all.ref
AUX=$($SRC/wer++.py $ALLHYP $ALLREF 2> /dev/null | grep "WER")
echo "$EP $AUX" 
} > $RES/res_$VMOD.$TASK.$SET.lr$LR.r$RANK.a$ALPHA.ep$EP.txt 
done 
done
done
done

done
