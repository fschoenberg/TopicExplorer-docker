#!/bin/bash
#this bash configures nginx, a topicexplorer for each user and a database

docker compose -f ../docker-compose-build-te.yml build topicexplorer

source <(grep = config.ini)

#create volume directories
mkdir -p "${NGINX_VOLUME_PATH}/config"
mkdir -p "${NGINX_VOLUME_PATH}/pw"
mkdir -p "${NGINX_VOLUME_PATH}/rules"
mkdir -p "${TE_VOLUME_PATH}"
mkdir -p "${DB_VOLUME_PATH}"
mkdir -p "${DB_VOLUME_PATH}/config"

#create db_config file
cat "templates/db-config-file.cnf" |\
sed "s/<DB_RAMSIZE>/$(echo $DB_RAMSIZE | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" > "${DB_VOLUME_PATH}/config/db-config-file.cnf"
chmod 700 "${DB_VOLUME_PATH}/config/db-config-file.cnf"

yes | cp -f "config.ini" "db/config.ini"
yes | cp -f "templates/nginx_default_header.conf" "templates/tmp_nginx"
yes | cp -f "templates/docker-compose-header.yml" "templates/tmp_docker"

htpasswd -c -b adminer.pw root $DB_ROOT_PW

for i in "${!USERS[@]}"
do 
    USER=${USERS[${i}]}
    USER_CAPS=$(echo ${USER} | tr '[:lower:]' '[:upper:]')
    PASSWORD=${PASSWORDS[${i}]}
    #create password file
    htpasswd -c -b $USER.pw $USER $PASSWORD
    htpasswd -b adminer.pw $USER $PASSWORD
    mv -f "$USER.pw" "${NGINX_VOLUME_PATH}/pw"

    mkdir -p "${TE_VOLUME_PATH}/${USER}"
    #create workflow file    
    cat "templates/start-topicexplorer-workflow-template-multiuser.html" |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
    sed "s/<DB_PREFIX>/$(echo ${USER_CAPS}_ | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" > "${TE_VOLUME_PATH}/${USER}/start-topicexplorer-workflow.html"

    #create startup file   
    cat "templates/startup-template.sh" |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
    sed "s/<PASSWORD>/$(echo ${PASSWORD} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" > "${TE_VOLUME_PATH}/${USER}/startup.sh"

    #create proxy config
    cat "templates/nginx_default_user.conf" |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >> "templates/tmp_nginx"
    
    #create docker config
    cat "templates/docker-compose-user.yml" |\
    sed "s/<TE_VOLUME_PATH>/$(echo $TE_VOLUME_PATH | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >> "templates/tmp_docker"

done 

mv -f "adminer.pw" "${NGINX_VOLUME_PATH}/pw"

#replace in Dockerfile
PROXY_DEP="$(printf "\055 topicexplorer-%s<newline>" "${USERS[@]}")"
cat "templates/docker-compose-footer.yml" |\
sed "s/<PROXY_DEP>/$(echo ${PROXY_DEP}| sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" |\
sed "s/<newline>/\n      /g" |\
sed "s/<DB_VOLUME_PATH>/$(echo $DB_VOLUME_PATH | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<DB_ROOT_PW>/$(echo $DB_ROOT_PW | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<SERVERPORT>/$(echo $SERVERPORT | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<HOST_URI>/$(echo $HOST_URI | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<NGINX_VOLUME_PATH>/$(echo $NGINX_VOLUME_PATH | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >> "templates/tmp_docker"
mv -f "templates/tmp_docker" "docker-compose.yml"


cat "templates/nginx_default_footer.conf" >>"templates/tmp_nginx"
mv -f "templates/tmp_nginx" "${NGINX_VOLUME_PATH}/config/default.conf.template"
yes | cp -f "templates/nginx-logging.conf.org" "${NGINX_VOLUME_PATH}/config/logging.conf.template"
yes | cp -f "templates/nginx-modsecurity.conf.org" "${NGINX_VOLUME_PATH}/config/modsecurity.conf.template"
yes | cp -f "RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf" "${NGINX_VOLUME_PATH}/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"

#build db with new config file
docker compose build topicexplorer-db
#start container
docker compose up