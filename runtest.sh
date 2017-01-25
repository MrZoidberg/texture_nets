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
  	echo "Resizing $filename file..."  
  	convert "${f}" -resize ${SIZE}x${SIZE}^ -gravity center -extent ${SIZE}x${SIZE} "resize/${filename}"
done

if [[ "${COLORS}" == "true" ]]; then
	th testbatch.lua -input_path resize -model_t7 ${MODEL} -save_path ${OUTPUT} -original_colors
	
else
	mkdir -p output_colors
	th testbatch.lua -input_path resize -model_t7 ${MODEL} -save_path output_colors
	for f in output_colors
	do
		filename=$(basename "$f")
	  	echo "Processing original colors $filename file..."  
	  	echo python color_transfer.py resize/${filename} f ${OUTPUT}/${filename}
	  	python color_transfer.py resize/${filename} f ${OUTPUT}/${filename}
	done
fi

rm -rf output_colors
rm -rf resize


