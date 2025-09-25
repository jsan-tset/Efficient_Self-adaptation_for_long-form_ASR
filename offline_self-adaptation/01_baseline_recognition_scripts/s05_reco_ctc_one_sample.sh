#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

mkdir -p logs

for TASK in LHCP-2020 LHCP-2022
do
    for SET in dev test
    do
        for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
        do
        VMOD=$(echo $MODEL | awk -F'_' '{print $3}')

        while read SPL
        do
            BNAME=$(basename $SPL .wav)
            if [[ ! -s baseline_chunked.$VMOD/$TASK/$SET/$BNAME/$BNAME.000.txt ]]
            then
            NAME=R_ctc_${VMOD}_${TASK}_${SET}_${BNAME}_1sample
            qsubmit -n $NAME \
                -o logs/$NAME.log \
                -m 20 -gmem 10G \
                scripts/wrp2bax_inf_one_sample.sh $SPL baseline_chunked.$VMOD $MODEL
            fi

        done < lists/audios_${TASK}_${SET}.lst

        done
    done
done

