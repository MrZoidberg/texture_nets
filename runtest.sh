#!/usr/bin/env bash

while getopts "i:o:s:" opt; do
case $opt in
i) SOURCE="$OPTARG"
;;
o) OUTPUT="$OPTARG"
;;
s) SIZE="$OPTARG"
;;
m) MODEL="$OPTARG"
;;
*) echo "No reasonable options found!";;
esac
done

mkdir -p resize

FILES=${SOURCE}/*
for f in $FILES
do
  echo "Processing $f file..."
  convert {SOURCE} -resize {SIZE}x{SIZE}^ -gravity center -extent {SIZE}x{SIZE} resize/{SOURCE}
done

th testbatch.lua -input_path resize -model_t7 ${MODEL} -save_path ${OUTPUT}

rm -rf resize/*


