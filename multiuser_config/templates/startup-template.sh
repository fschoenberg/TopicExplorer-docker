#!/bin/bash

#local configuration variables
DBUSER="<USER>"
DBPASSWORD="<PASSWORD>"

#exported configuration variables
export TE_WEBSERVER=topicexplorer-<USER>


function create_db_if_not_exists {
  RESULT=$(mysqlshow --user=$DBUSER --password=$DBPASSWORD -h topicexplorer-db $1| grep -v Wildcard | grep -o $1)

  if [ "$RESULT" == "$1" ]; then
      echo Database $1 does exists
      #replace tedb_user_login.cnf file in case the password was changed since the last run
      bash -c ./install/create_tedb_login.sh
  else
    echo Database $1 does not exists
    export TE_MANAGEMENT_DB_NAME=$1
    bash -c ./install/create_tedb.sh
  fi
}

# wait for mariadb
until mysql -u $DBUSER --password=$DBPASSWORD -h  topicexplorer-db; do
  >&2 echo "Mariadb is unavailable"
  >&2 echo "Check your login credentials if this message appears after mariadb is up and accepting connections."
  sleep 5
done

>&2 echo "Mariadb is up - executing command"
>&2 echo "Environment variables from docker"
>&2 echo "TE_BASE_DIR=$TE_BASE_DIR"
>&2 echo "TE_VERSION=$TE_VERSION"

export DBUSER_CAPS=$(echo ${DBUSER} | tr '[:lower:]' '[:upper:]')
#Set a prefix to bind the db to the user
export TE_IDENTIFIER_DB_PREFIX="$DBUSER_CAPS"_
#export TE_IDENTIFIER_DB_PREFIX=""
export TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT
export MYSQL_TE_MANAGEMENT_LOGIN_FILE="$TE_BASE_DIR"/config/tedb_user_login.cnf
export USER_AT_WEBAPP_SERVER=root@$TE_WEBSERVER
export TE_WEBAPP_BASE_DIR=/topicexplorer/apache-tomcat-6.0.53/webapps
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_jp
export TE_DBSERVER=topicexplorer-db
export TE_DBSERVER_4MYSQL=%
export TE_MANAGEMENT_DB_USER=$DBUSER
export TE_MANAGEMENT_DB_PASSWORD=$DBPASSWORD

create_db_if_not_exists ${DBUSER_CAPS}_TE_MANAGEMENT_JP_MECAB
create_db_if_not_exists ${DBUSER_CAPS}_TE_MANAGEMENT_DE_TREETAGGER
create_db_if_not_exists ${DBUSER_CAPS}_TE_MANAGEMENT_EN_TREETAGGER

#if password changed the copy of the cnf will differ from the new cnf
#in this case find all properties files with the property 'DbPassword' and replace it
if ! $(cmp --silent "$MYSQL_TE_MANAGEMENT_LOGIN_FILE" "${MYSQL_TE_MANAGEMENT_LOGIN_FILE}.copy"); then
  echo "password changed till the last run => update password for user ${DBUSER}"
  PROPFILES=($(find /topicexplorer/ -type f -name '*.properties' -exec grep -l "DbPassword=[^<]" {} \;))
  for PROPFILE in "${PROPFILES[@]}"
  do
    sed -i "/^DbPassword=/c\DbPassword=${DBPASSWORD}" $PROPFILE
    echo $PROPFILE
  done
fi
yes | cp -f "$MYSQL_TE_MANAGEMENT_LOGIN_FILE" "${MYSQL_TE_MANAGEMENT_LOGIN_FILE}.copy"

export JRE_HOME=/usr/lib/jvm/default-java
cd /topicexplorer/apache-tomcat-6.0.53
cp -R webapp_basics/* webapps/
./bin/startup.sh

cd /topicexplorer/jobson-server
jobson serve config.yml &

cd /topicexplorer

# german
export TE_MANAGEMENT_DB_NAME=${DBUSER_CAPS}_TE_MANAGEMENT_DE_TREETAGGER
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_de_treetagger
export TE_TMP="$TE_BASE_DIR"/helper/tmp_de_treetagger
./creator-server \
     --port 7202 \
     --script-dir=/topicexplorer/script \
     --app-server=../../../webapp/ &

# englisch
export TE_MANAGEMENT_DB_NAME=${DBUSER_CAPS}_TE_MANAGEMENT_EN_TREETAGGER
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_en_treetagger
export TE_TMP="$TE_BASE_DIR"/helper/tmp_en_treetagger
./creator-server \
     --port 7201 \
     --script-dir=/topicexplorer/script \
     --app-server=../../../webapp/ &

# japanese
export TE_MANAGEMENT_DB_NAME=${DBUSER_CAPS}_TE_MANAGEMENT_JP_MECAB
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_jp_mecab
export TE_TMP="$TE_BASE_DIR"/helper/tmp_jp_mecab
./creator-server \
     --port 7200 \
     --script-dir=/topicexplorer/script \
     --app-server=../../../webapp/ #\
#      >>creator-nohup.out 2>creator-nohup.err
