#!/usr/bin/env bash
file=$1
trf=$2
tef=$3

l=$(wc -l $file |cut -d' ' -f1)
h=$((3*l/5))
t=$((2*l/5))

head -n $h $file > $trf
tail -n $t $file > $tef

echo "successfully splat the files."
