#!/bin/bash

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

RESULT=`mysqlshow --user=root --password=$(cat /topicexplorer/te_mysql_password) -h topicexplorer-db TE_MANAGEMENT| grep -v Wildcard | grep -o TE_MANAGEMENT`
if [ "$RESULT" == "TE_MANAGEMENT" ]; then
    echo Database TE_MANAGEMENT does exists
else
  echo Database TE_MANAGEMENT does not exists
  bash -c ./install/create_tedb.sh
fi

export JRE_HOME=/usr/lib/jvm/default-java
cd /topicexplorer/apache-tomcat-6.0.53
cp -R webapp_basics/* webapps/
./bin/startup.sh

cd /topicexplorer
./creator-server \
     --script-dir=/topicexplorer/script \
     --app-server=/webapp/ #\
#      >>creator-nohup.out 2>creator-nohup.err
