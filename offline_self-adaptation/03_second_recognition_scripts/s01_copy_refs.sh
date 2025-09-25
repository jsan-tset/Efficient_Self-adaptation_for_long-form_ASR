#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

# Copy references into one file (one sample/line)

ORI=/home/jausanjo/wrk/stepper_adapt_origins/02_espnet/06_OWSM_LHCP_video
SCR=~/asr-scripts/asr-scripts/lm/prepro

source /home/jausanjo/pyth_envs/prepro/bin/activate
for TASK in LHCP-2020 LHCP-2022
do
for SET in dev test
do
    DST=ref/$TASK/$SET; mkdir -p $DST
    find $ORI/raw/$TASK/$SET/ -name '*.ref' -exec cp {} $DST/ \;

    find ref/$TASK/$SET/ -name '*.ref' | sort -V |
        while read R
        do
            echo $R
            cat $R | $SCR/prepro_am.sh en > $R.tmp
            mv $R.tmp $R
            cat $R
        done > ref/$TASK/$SET/all.ref
done
done
