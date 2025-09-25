#!/bin/bash

set -e

export LC_ALL=C.UTF-8

mkdir -p TMPlogs

for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
do
VMOD=$(echo $MODEL | awk -F'_' '{print $3}')

for TASK in LHCP-2020 LHCP-2022
do
SET=test #dev

for EP in {1..5}
do

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

cat lists/samples_${TASK}_${SET}.lst |
    while read SPL
    do


NSPL=$(echo $SPL | sed 's/^.*c/c/')
NAME=R.${VMOD}.${NSPL}.lr$LR.r$RANK.a$ALPHA.${TASK}.${SET}.e$EP
echo $NAME
qsubmit -n $NAME \
    -o logs/$NAME.log \
    -m 20 -gmem 10G \
    scripts/wrp2ft_inference_one_sample_rank.sh \
    wavs/$TASK/$SET/$SPL.wav \
    exp.$VMOD/lr$LR.r$RANK.a$ALPHA/$TASK/$NSPL/finetune/${EP}epoch.pth \
    out_hyp.$VMOD/lr$LR.r$RANK.a$ALPHA \
    $MODEL \
    $RANK $ALPHA

done

done
done
done

done
done
