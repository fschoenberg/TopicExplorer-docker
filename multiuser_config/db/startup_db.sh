#!/bin/bash
echo "starting db"

###########################
#starts the database deamon
###########################
docker-entrypoint.sh mariadbd &
#wait to come up
timeout 15 bash -c 'until echo > /dev/tcp/localhost/3306; do sleep 0.5; done'

###################################
#enable / disable query logging
###################################
source <(grep = /te_user_creation/config.ini)
if [ ! -v ENABLE_QUERY_LOGGING ]; then
    sleep 1
    #disable query logging
    mysql -u root --password=$DB_ROOT_PW -e "SET GLOBAL general_log = 0;"
else
    #enable query logging
    rm /var/log/mysql/general.log
    touch /var/log/mysql/general.log
    chmod 777 /var/log/mysql/general.log
    sleep 5
    echo enable query logging
    mysql -u root --password=$DB_ROOT_PW -e "SET GLOBAL general_log = 1;"
    mysql -u root --password=$DB_ROOT_PW -e "SET GLOBAL general_log_file='/var/log/mysql/general.log';"
fi

###########################
#create user
###########################
function create_db_user {
  
  #Write SQL commands to QUERY variable
  read -r -d '' QUERY << \
_______________________________________________________________________________

  CREATE USER '${USER}'@'%' IDENTIFIED BY '${TE_MANAGEMENT_DB_PASSWORD}';
  GRANT USAGE ON *.* TO '${USER}'@'%' REQUIRE NONE;
  GRANT ALL PRIVILEGES ON $(echo -e '\u0060')${USER_CAPS}\_%$(echo -e '\u0060').* TO '${USER}'@'%' WITH GRANT OPTION; 
  GRANT SELECT \($(echo -e '\u0060')User$(echo -e '\u0060')\) ON mysql.user TO '${USER}'@'%';
_______________________________________________________________________________

  #echo ${QUERY}
  mysql -u root --password=$DB_ROOT_PW -s -e "${QUERY}"
}

###########################
#change password
###########################
function change_db_password {
  
  #Write SQL commands to QUERY variable
  read -r -d '' QUERY << \
_______________________________________________________________________________

  ALTER USER '${USER}'@'%' IDENTIFIED BY '${TE_MANAGEMENT_DB_PASSWORD}';
  FLUSH PRIVILEGES;
_______________________________________________________________________________

  #echo ${QUERY}
  mysql -u root --password=$DB_ROOT_PW -s -e "${QUERY}"
}

for i in "${!USERS[@]}"
do 
    USER=${USERS[${i}]}
    USER_CAPS=$(echo ${USER} | tr '[:lower:]' '[:upper:]')
    PASSWORD=${PASSWORDS[${i}]}
    TE_MANAGEMENT_DB_PASSWORD=$PASSWORD
    TE_MANAGEMENT_DB_USER=$USER
    #Query for existing user
    QUERY="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${USER}');"
    RESULT=$(mysql -u root --password=$DB_ROOT_PW -s -e "${QUERY}")
    if [[ "$RESULT" == "0" ]]; then
      create_db_user
      echo "Nutzer ${USER} wurde angelegt"
    else
      #Renew password in case of changes
      change_db_password
    fi
done 

######################################
#keep service running and trap SIGTERM
######################################
die_func() {
        echo "quit db service"
        exit 1
}
trap die_func TERM

sleep infinity 
wait

