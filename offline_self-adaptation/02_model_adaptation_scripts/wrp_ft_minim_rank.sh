#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

if [[ $# != 8 ]]
then
    echo "$0 <train_csv> <valid_csv> <outdir> <model> <learning_rate> <lora_rank> <lora_alpha> <conf.yaml>" >&2
    exit 1
fi

TCSV=$1
VCSV=$2
ODIR=$3; mkdir -p $3
MODL=$4
LR=$5
RANK=$6
ALPH=$7
CONF=$8

source /home/jausanjo/tools/espnet/tools/venv/bin/activate

python scripts/ft_minim_rank.py $TCSV $VCSV $ODIR $MODL $LR $RANK $ALPH $CONF

deactivate
