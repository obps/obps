#!/usr/bin/env sh

for f in $@;
do
  flow=$(cat $f | awk -f misc/visu/flow.awk)
  echo "$flow $(basename $f)"
done
