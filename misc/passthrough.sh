#!/usr/bin/env bash

csv=$1
mcts=$2
h1=$3
h2=$4
out=$5

wmcts=$(cat $mcts| cut -d' ' -f1)
wh1=$(cat $h1| cut -d' ' -f1)
wh2=$(cat $h2| cut -d' ' -f1)
wcl=$(wc -l $csv|cut -d' ' -f1)

if [ "$wcl" -lt "3" ]
then
  touch $out
  exit 0
fi

btest=$( echo "$wmcts < 10" | bc)


if [ $btest -eq 1 ]
then
  touch $out
  exit 0
fi


weight=$(echo "$wmcts $wh1 $wh2 $wcl" | awk '{print (($2+$3)/2 - $1 )/$4 }' )

wmax=$(awk -F , 'max < $1 { max = $1 } END { print max }' $csv)

wmin=$(awk -F , 'NR == 1 || m > $1 { m = $1 } END { print m }' $csv)
echo $wmcts $wh1 $wh2 $wcl

btest=$( echo "$wmax - $wmin < 0.01" | bc)

echo $wmcts $wh1 $wh2 $wcl

if [ "$btest" -eq 1 ]
then
  awkstr=$(echo "\$1=\$1 * $weight")
else
  awkstr=$(echo "\$1=(\$1-$wmin)/(($wmax-$wmin)*$weight)")
fi


echo $wmcts $wh1 $wh2 $wcl

cat $csv | awk -F , -v OFS=, $awkstr > $out
