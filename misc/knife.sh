#!/bin/sh

lines=$(wc -l $1 |cut -f1 -d' ')

head $1 -n $((lines/3)) > $2
