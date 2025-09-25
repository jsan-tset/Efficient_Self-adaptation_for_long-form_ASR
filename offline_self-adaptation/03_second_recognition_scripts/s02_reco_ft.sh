#!/bin/bash

set -e

export LC_ALL=C.UTF-8

mkdir -p logs

for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
do
VMOD=$(echo $MODEL | awk -F'_' '{print $3}')

for TASK in LHCP-2020 LHCP-2022
do
    for SET in dev #test
    do
        for EP in 5
        do
        cat lists/samples_${TASK}_${SET}.lst |
            while read SPL
            do
                NSPL=$(echo $SPL | sed 's/^.*c/c/')
                NAME=R.$VMOD.${NSPL}.${TASK}.${SET}
                qsubmit -n $NAME \
                    -o logs/$NAME.log \
                    -m 20 -gmem 10G \
                    scripts/wrp2ft_inference_one_sample.sh \
                        wavs/$TASK/$SET/$SPL.wav \
                        exp.$VMOD/$TASK/$NSPL/finetune/${EP}epoch.pth \
                        out_hyp.$VMOD \
                        $MODEL
            done
        done
    done
done

done
