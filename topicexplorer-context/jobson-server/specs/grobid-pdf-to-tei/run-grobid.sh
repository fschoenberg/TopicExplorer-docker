#!/bin/bash
INPUT_FOLDER=$1
GROBID_SERVICE=$2
NUMBER_OF_REQUESTS=$3

if [[ ! $INPUT_FOLDER =~ ^[A-Z][_0-9A-Z]{0,44}$ ]]; then
    echo "The folder name $INPUT_FOLDER is not a valid corpus identifier. Rename the folder such that is starts with capital letter and uses only capital letters, numbers and underscore but no whitespaces. Maximum length is 45 characters."
    exit 1
fi

TOPICEXPLORER_PATH="/topicexplorer"
INPUT_FOLDER_PREFIX_PATH="${TOPICEXPLORER_PATH}/input-corpora/pdf"
OUPUT_FOLDER_PREFIX_PATH="${TOPICEXPLORER_PATH}/input-corpora/text"
FULL_INPUT_FOLDER="${INPUT_FOLDER_PREFIX_PATH}/${INPUT_FOLDER}"
FULL_OUTPUT_FOLDER="${OUTPUT_FOLDER_PREFIX_PATH}/${INPUT_FOLDER}"
GROBID_JAR="${TOPICEXPLORER_PATH}/grobid-client-java/org.grobid.client-0.5.4-SNAPSHOT.one-jar.jar"
echo "java -jar ${GROBID_JAR} -in ${FULL_INPUT_FOLDER} -out ${FULL_OUTPUT_FOLDER} -exe ${GROBID_SERVICE} -n ${NUMBER_OF_REQUESTS}"

java -jar ${GROBID_JAR} -in ${FULL_INPUT_FOLDER} -out ${FULL_OUTPUT_FOLDER} -exe ${GROBID_SERVICE} -n ${NUMBER_OF_REQUESTS}

exit $?
