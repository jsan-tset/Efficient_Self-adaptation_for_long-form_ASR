#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

# contains basic preprocessing scripts
# (num2text, upper to lower case, undo abbreviations, etc.)
SCR=~/asr-scripts/lm/prepro

source /home/jausanjo/pyth_envs/prepro/bin/activate

for TASK in LHCP-2020 LHCP-2022
do
    for SET in test
    do
        for MODEL in "espnet/owsm_ctc_v3.1_1B" "espnet/owsm_ctc_v3.2_ft_1B" "espnet/owsm_ctc_v4_1B"
        do
            VMOD=$(echo $MODEL | awk -F'_' '{print $3}')
            for SPL in `find baseline_out.$VMOD/$TASK/$SET -name "[0-9]*.txt"`
            do
                NAME=`basename $SPL`
                cat $SPL |
                    $SCR/prepro_am.sh en > $SPL.post  
                sed -e 's|<oov>||g' -e 's/ uh / /g' -e 's/ um / /g' $SPL.post | sed -e 's/ uh / /g' -e 's/ um / /g' > $SPL.post.clean
            done
            find baseline_out.$VMOD/$TASK/$SET -name "[0-9]*.txt.post.clean" | sort -V |
                while read SPL
                do
                    cat $SPL
                done > baseline_out.$VMOD/${TASK}/${SET}/all.txt.post.clean
        done
    done
done

deactivate
