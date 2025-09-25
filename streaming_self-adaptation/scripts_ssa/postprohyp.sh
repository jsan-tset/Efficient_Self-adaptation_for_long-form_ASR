#!/bin/bash

set -e

export LC_ALL=C.UTF-8

if [[ $# != 1 ]]
then 
    echo "$0 <full.hyp>"
    exit 1
fi

HYP=$1

source /home/jausanjo/pyth_envs/prepro/bin/activate
cat $HYP | ~/asr-scripts/asr-scripts/lm/prepro/prepro_am.sh en > $HYP.post
deactivate

sed -e 's/<oov>//g' -e 's/ uh / /g' -e 's/ um / /g' $HYP.post |
    sed -e 's/<oov>//g' -e 's/ uh / /g' -e 's/ um / /g' > $HYP.post.clean
