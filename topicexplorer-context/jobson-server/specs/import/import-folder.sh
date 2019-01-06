#!/bin/bash


CORPUS_IDENTIFIER=$1
TE_MANAGEMENT_DB_NAME=$2

if [[ ! $CORPUS_IDENTIFIER =~ ^[A-Z][_0-9A-Z]{0,44}$ ]]; then
    echo "The folder name $CORPUS_IDENTIFIER is not a valid corpus identifier. Rename the folder such that is starts with capital letter and uses only capital letters, numbers and underscore but no whitespaces. Maximum length is 45 characters."
    exit 1
fi

#check for db name of TE_MANAGEMENT
if [ ! -v TE_MANAGEMENT_DB_NAME ]; then
    echo "environment variable TE_MANAGEMENT_DB_NAME for name of TE_MANAGEMENT database is not set: example TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT"
    exit 1
fi

#check for db-server to grant mysql access from the correct server
if [ ! -v TE_DBSERVER ]; then
    echo "environment variable TE_DBSERVER to grant mysql access from the correct server is not set: example TE_DBSERVER=topicexplorer.uni-halle.de"
    exit 1
fi

#check for
if [ ! -v TE_MANAGEMENT_DB_USER ]; then
    echo "environment variable TE_MANAGEMENT_DB_USER for the user of the TopicExplorer database is not set: example TE_MANAGEMENT_DB_USER=te_user"
    exit 1
fi

#check for
if [ ! -v TE_MANAGEMENT_DB_PASSWORD ]; then
    echo "environment variable TE_MANAGEMENT_DB_PASSWORD for the user of the TopicExplorer database is not set: example TE_MANAGEMENT_DB_PASSWORD=secret"
    exit 1
fi

#replace placeholders in temporary config files
sed -i -- "s/<TE_DBSERVER>/$(echo $TE_DBSERVER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" cmdb.local.properties
sed -i -- "s/<TE_MANAGEMENT_DB_NAME>/$(echo $TE_MANAGEMENT_DB_NAME | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"  cmdb.local.properties
sed -i -- "s/<TE_MANAGEMENT_DB_USER>/$(echo $TE_MANAGEMENT_DB_USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"  cmdb.local.properties
sed -i -- "s/<TE_MANAGEMENT_DB_PASSWORD>/$(echo $TE_MANAGEMENT_DB_PASSWORD | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"  cmdb.local.properties

java -Dfile.encoding=UTF-8 -classpath "/topicexplorer/te-production/distribution/standard/lib/*:." cc.topicexplorer.dataimport.ImportFolder --folder /topicexplorer/input-corpora/text/${CORPUS_IDENTIFIER}

exit $?
