#!/bin/bash

function create_db_if_not_exists {
  RESULT=$(mysqlshow --user=root --password=$(cat /topicexplorer/te_mysql_password) -h topicexplorer-db $1| grep -v Wildcard | grep -o $1)

  if [ "$RESULT" == "$1" ]; then
      echo Database $1 does exists
  else
    echo Database $1 does not exists
    export TE_MANAGEMENT_DB_NAME=$1
    bash -c ./install/create_tedb.sh
  fi
}

# wait for mariadb
until mysql -u root --password=$(cat /topicexplorer/te_mysql_password) -h  topicexplorer-db; do
  >&2 echo "Mariadb is unavailable"
  >&2 echo "Check your login credentials if this message appears after mariadb is up and accepting connections."
  sleep 5
done

>&2 echo "Mariadb is up - executing command"
>&2 echo "Environment variables from docker"
>&2 echo "TE_BASE_DIR=$TE_BASE_DIR"
>&2 echo "TE_VERSION=$TE_VERSION"

export MYSQL_ROOT_PASSWORD_FILE=/topicexplorer/te_mysql_password
export TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT
export MYSQL_TE_MANAGEMENT_LOGIN_FILE="$TE_BASE_DIR"/config/tedb_user_login.cnf
export USER_AT_WEBAPP_SERVER=root@topicexplorer
export TE_WEBAPP_BASE_DIR=/topicexplorer/apache-tomcat-6.0.53/webapps
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_jp
export TE_WEBSERVER=topicexplorer
export TE_DBSERVER=topicexplorer-db
export TE_DBSERVER_4MYSQL=%
export TE_MANAGEMENT_DB_USER=root
export TE_MANAGEMENT_DB_PASSWORD=$(cat /topicexplorer/te_mysql_password)

create_db_if_not_exists TE_MANAGEMENT_JP_MECAB
create_db_if_not_exists TE_MANAGEMENT_DE_TREETAGGER
create_db_if_not_exists TE_MANAGEMENT_EN_TREETAGGER

export JRE_HOME=/usr/lib/jvm/default-java
cd /topicexplorer/apache-tomcat-6.0.53
cp -R webapp_basics/* webapps/
./bin/startup.sh


cd /topicexplorer

# german
export TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT_DE_TREETAGGER
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_de_treetagger
export TE_TMP="$TE_BASE_DIR"/helper/tmp_de_treetagger
./creator-server \
     --port 7202 \
     --script-dir=/topicexplorer/script \
     --app-server=/webapp/ &

# englisch
export TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT_EN_TREETAGGER
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_en_treetagger
export TE_TMP="$TE_BASE_DIR"/helper/tmp_en_treetagger
./creator-server \
     --port 7201 \
     --script-dir=/topicexplorer/script \
     --app-server=/webapp/ &

# japanese
export TE_MANAGEMENT_DB_NAME=TE_MANAGEMENT_JP_MECAB
export TE_CONFIG_TEMPLATE_BLOGS_JP="$TE_BASE_DIR"/helper/te_config_template_jp_mecab
export TE_TMP="$TE_BASE_DIR"/helper/tmp_jp_mecab
./creator-server \
     --port 7200 \
     --script-dir=/topicexplorer/script \
     --app-server=/webapp/ #\
#      >>creator-nohup.out 2>creator-nohup.err
