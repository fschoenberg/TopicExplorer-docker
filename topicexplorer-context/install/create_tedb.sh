#!/bin/bash

#check for te base directory
if [ ! -v TE_BASE_DIR ]; then
    echo "environment variable TE_BASE_DIR for the te base directory is not set: example TE_BASE_DIR=/te_production"
    exit 1
fi

#check if $TE_BASE_DIR/config dir exists
if [ ! -d "$TE_BASE_DIR"/config ]; then
    echo "The directory for the config files does not exists: $TE_BASE_DIR/config"
    exit 1
fi

#check for db name of TE_MANAGEMENT
if [ ! -v TE_MANAGEMENT_DB_NAME ]; then
    echo "environment variable TE_MANAGEMENT_DB_NAME for name of TE_MANAGEMENT database is not set: example TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT"
    exit 1
fi


#check for web-server to grant mysql access from the correct server
if [ ! -v TE_WEBSERVER ]; then
    echo "environment variable TE_WEBSERVER to grant mysql access from the correct server is not set: example TE_WEBSERVER=topicexplorer.uni-halle.de"
    exit 1
fi

#check for db-server to grant mysql access from the correct server
if [ ! -v TE_DBSERVER_4MYSQL ]; then
    echo "environment variable TE_DBSERVER_4MYSQL to grant mysql access from the correct server is not set: example TE_DBSERVER_4MYSQL=topicexplorer.uni-halle.de"
    exit 1
fi

#check for db-server to grant mysql access from the correct server
if [ ! -v TE_DBSERVER ]; then
    echo "environment variable TE_DBSERVER to grant mysql access from the correct server is not set: example TE_DBSERVER=topicexplorer.uni-halle.de"
    exit 1
fi

#check for TE_MANAGEMENT_DB_USER
if [ ! -v TE_MANAGEMENT_DB_USER ]; then
    echo "environment variable TE_MANAGEMENT_DB_USER for mysql access from the correct server is not set: example TE_MANAGEMENT_DB_USER=root"
    exit 1
fi

#check for TE_MANAGEMENT_DB_PASSWORD
if [ ! -v TE_MANAGEMENT_DB_PASSWORD ]; then
    echo "environment variable TE_MANAGEMENT_DB_PASSWORD for mysql access from the correct server is not set: example TE_MANAGEMENT_DB_PASSWORD=mypassword"
    exit 1
fi

# create sql commands
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


TEDB_USER_LOGIN="$TE_BASE_DIR"/config/tedb_user_login.cnf
cat "$SOURCE"/tedb_user_login.cnf |\
sed "s/<TE_MANAGEMENT_DB_NAME>/$(echo $TE_MANAGEMENT_DB_NAME | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<TE_MANAGEMENT_DB_USER>/$(echo $TE_MANAGEMENT_DB_USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<TE_MANAGEMENT_DB_PASSWORD>/$(echo $TE_MANAGEMENT_DB_PASSWORD | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >"$TEDB_USER_LOGIN"
chmod 600 "$TEDB_USER_LOGIN"

TE_MANAGEMENT_DB_CREATION="$TE_BASE_DIR"/config/te-management-db-creation.sql
cat $SOURCE/te-management-db-creation.sql |\
sed "s/<TE_MANAGEMENT_DB_NAME>/$(echo $TE_MANAGEMENT_DB_NAME | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"    > "$TE_MANAGEMENT_DB_CREATION"

 printf "Run as $TE_MANAGEMENT_DB_USER user:\n\nmysql --defaults-extra-file=$TEDB_USER_LOGIN <$TE_MANAGEMENT_DB_CREATION\n\n"

more $TEDB_USER_LOGIN
more $TE_MANAGEMENT_DB_CREATION

mysql --defaults-extra-file=$TEDB_USER_LOGIN  <$TE_MANAGEMENT_DB_CREATION
