#!/bin/bash

INPUT_FOLDER=$1
OUTPUT_DESTINATION=$2
OUTPUT_FOLDER=$3
RECURSIVE=$4

if [ ! -d  "/topicexplorer/input-corpora/pdf/$INPUT_FOLDER" ]; then
    echo "Input folder $INPUT_FOLDER does not exists in ./volumes/input-corpora/pdf/"
    exit 1
fi

if [ $RECURSIVE = "do-search-all-subdirs-and-flatten-path" ]; then
  mkdir ${INPUT_FOLDER}_tmp
  . subdirs.sh
  link_to_subdirs "/topicexplorer/input-corpora/pdf/${INPUT_FOLDER}" "${INPUT_FOLDER}_tmp" ".pdf"
  INPUT_FOLDER="${INPUT_FOLDER}_tmp"
else
  INPUT_FOLDER="/topicexplorer/input-corpora/pdf/$INPUT_FOLDER"
fi

mkdir ${OUTPUT_FOLDER}
if [ ! -d "$OUTPUT_FOLDER" ]; then
  echo "Error: can not create output folder $OUTPUT_FOLDER."
fi

echo "Starting to convert pdf files ..."

# for filename in /topicexplorer/input-corpora/pdf/${INPUT_FOLDER}/*; do
for filename in ${INPUT_FOLDER}/*; do
  [ -e "$filename" ] || continue
  target_filename=$(basename "$filename")
  echo "convert $filename to $target_filename.txt"
  pdftotext "$filename" ${OUTPUT_FOLDER}/"$target_filename".txt
done

echo "Successfully converted pdf files."


echo "Starting to zip output folder ${OUTPUT_FOLDER} ..."

zip -r output.zip  ${OUTPUT_FOLDER}
echo "Successfully zipped output folder."

RETURN_CODE=0
if [ $OUTPUT_DESTINATION = "InputForCorpusImport" ]; then
    echo "Trying to save output folder as input folder for corpus import."
    if [ -d  "/topicexplorer/input-corpora/text/$OUTPUT_FOLDER" ]; then
      echo "Error: output folder $OUTPUT_FOLDER does already exists in ./volumes/input-corpora/text/ . Choose another name for output folder."
      rm -r ${OUTPUT_FOLDER}
      RETURN_CODE=1
    else
      mv ${OUTPUT_FOLDER} /topicexplorer/input-corpora/text/$OUTPUT_FOLDER
      echo "Successfully moved ${OUTPUT_FOLDER} to ./volumes/input-corpora/text/$OUTPUT_FOLDER"
    fi
else
  rm -r ${OUTPUT_FOLDER}
fi

exit $RETURN_CODE
