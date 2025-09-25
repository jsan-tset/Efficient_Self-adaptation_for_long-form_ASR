#!/bin/bash

set -e

for TASK in LHCP-2020 LHCP-2022
do
for SET in dev test
do
    DIR=csv/$TASK/$SET; mkdir -p $DIR

    for DVID in raw/$TASK/$SET/*
    do
        NAME=`basename $DVID`
        ODVID=valid_chunked/$TASK/$SET/$NAME
        bash scripts/segment_and_csv.sh $DVID/$NAME.srt wavs/$TASK/$SET/$NAME.wav $ODVID $DIR/$NAME.csv
    done
done
done

