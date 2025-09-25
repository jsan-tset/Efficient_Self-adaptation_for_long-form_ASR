#!/bin/bash

set -e

export LC_ALL=C.UTF-8

if [[ $# != 2 ]]
then 
    echo "$0 <DIR> <EPOCH>"
    exit 1
fi

DIR=$1
EPOCH=$2

if [[ $EPOCH -le 1 ]]
then
    exit 1
fi
DELUNTILEP=$((EPOCH - 1))
for EP in $(seq 1 $DELUNTILEP)
do
    rm $DIR/finetune/${EP}epoch.pth
done
