#!/bin/bash

set -e

export LC_ALL=C.UTF-8

SCR=~/asr-scripts/asr-scripts/lm/prepro

for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
do
VMOD=$(echo $MODEL | awk -F'_' '{print $3}')

for TASK in LHCP-2020
do
    for SET in dev #test
    do
        for EP in 5
        do
            find out_hyp.$VMOD/$TASK/$SET -name "[0-9]*.ep$EP.txt" | sort -V |
            while read TXT
            do
                echo "$TXT"

                source /home/jausanjo/pyth_envs/prepro/bin/activate
                cat $TXT | $SCR/prepro_am.sh en > $TXT.post
                deactivate

                HYP=$TXT.post.clean
                sed 's/<oov>//g' $TXT.post > $HYP
            done
            find out_hyp.$VMOD/$TASK/$SET -name "[0-9]*.ep$EP.txt.post.clean" | sort -V |
                while read l
                do
                    cat $l
                done > out_hyp.$VMOD/${TASK}/${SET}/all.ep$EP.txt.post.clean
        done
    done
done

done
