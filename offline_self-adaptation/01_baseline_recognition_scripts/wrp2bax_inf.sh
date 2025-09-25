#!/bin/bash

set -xe

export LC_ALL=C.UTF-8

if [[ $# != 3 ]]
then
    echo "$0 <AUDIO_LST> <OUTPUT_DIR> <MODEL>" >&2
    exit 1
fi

ILST=$1
ODIR=$2
MODL=$3

source /home/jausanjo/tools/espnet/tools/venv/bin/activate

python scripts/batched_inference.py $ILST $ODIR $MODL

deactivate
