#!/usr/bin/env bash

mkdir ~/annex/experiments/$1
cp -r o pdfs ~/annex/experiments/$1
git log | head -n 1 > ~/annex/experiments/$1/metadata
cd ~/annex/experiments
echo "adding"
git annex add $1
git commit -m "added experiment: $1" -a
