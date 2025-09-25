#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

if [[ $# != 4 ]]
then
    echo "$0 <AUDIO_PATH> <CHKP_PATH> <OUTPUT_DIR> <MODEL>" >&2
    exit 1
fi

APTH=$1
CHKP=$2
ODIR=$3; mkdir -p $ODIR
MODL=$4

source /home/jausanjo/tools/espnet/tools/venv/bin/activate

python scripts/reco_ft.py $APTH $CHKP $ODIR $MODL

deactivate
