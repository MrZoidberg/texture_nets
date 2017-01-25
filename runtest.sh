#!/usr/bin/env bash

while getopts "i:o:s:m:c:" opt; do
case $opt in
i) SOURCE="$OPTARG"
;;
o) OUTPUT="$OPTARG"
;;
s) SIZE="$OPTARG"
;;
m) MODEL="$OPTARG"
;;
c) COLORS="$OPTARG"
;;
*) echo "No reasonable options found!";;
esac
done

mkdir -p resize

FILES=${SOURCE}/*
for f in $FILES
do
	filename=$(basename "$f")
  	echo "Processing $filename mifile..."  
  	convert "${f}" -resize ${SIZE}x${SIZE}^ -gravity center -extent ${SIZE}x${SIZE} "resize/${filename}"
done

th testbatch.lua -input_path resize -model_t7 ${MODEL} -save_path ${OUTPUT} -original_colors ${COLORS}

rm -rf resize


