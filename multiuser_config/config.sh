#!/bin/bash
#this bash configures nginx, a topicexplorer for each user and a database

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi




source <(grep = config.ini)

#create volume directories
mkdir -p "${NGINX_VOLUME_PATH}"
mkdir -p "${TE_VOLUME_PATH}"
mkdir -p "${DB_VOLUME_PATH}"

#create db_config file
cat "templates/db-config-file.cnf" |\
sed "s/<DB_RAMSIZE>/$(echo $DB_RAMSIZE | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >"db/db-config-file.cnf"

yes | cp -f "config.ini" "db/config.ini"
yes | cp -f "templates/nginx_default_header.conf" "templates/tmp_nginx"
yes | cp -f "templates/docker-compose-header.yml" "templates/tmp_docker"
for i in "${!USERS[@]}"
do 
    USER=${USERS[${i}]}
    USER_CAPS=$(echo ${USER} | tr '[:lower:]' '[:upper:]')
    PASSWORD=${PASSWORDS[${i}]}
    #create password file
    htpasswd -c -b $USER.pw $USER $PASSWORD
    mv -f "$USER.pw" "${NGINX_VOLUME_PATH}"

    mkdir -p "${TE_VOLUME_PATH}/${USER}"
    #create workflow file    
    cat "templates/start-topicexplorer-workflow-template-multiuser.html" |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
    sed "s/<DB_PREFIX>/$(echo ${USER_CAPS}_ | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >> "${TE_VOLUME_PATH}/${USER}/start-topicexplorer-workflow.html"

    #create startup file   
    cat "templates/startup-template.sh" |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
    sed "s/<PASSWORD>/$(echo ${PASSWORD} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >> "${TE_VOLUME_PATH}/${USER}/startup.sh"

    #create proxy config
    cat "templates/nginx_default_user.conf" |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >>"templates/tmp_nginx"
    
    #create docker config
    cat "templates/docker-compose-user.yml" |\
    sed "s/<TE_VOLUME_PATH>/$(echo $TE_VOLUME_PATH | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
    sed "s/<USER>/$(echo $USER | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >>"templates/tmp_docker"

done 

#replace in Dockerfile
PROXY_DEP="$(printf "\055 topicexplorer-%s<newline>" "${USERS[@]}")"
cat "templates/docker-compose-footer.yml" |\
sed "s/<PROXY_DEP>/$(echo ${PROXY_DEP}| sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" |\
sed "s/<newline>/\n      /g" |\
sed "s/<DB_VOLUME_PATH>/$(echo $DB_VOLUME_PATH | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<DB_ROOT_PW>/$(echo $DB_ROOT_PW | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<SERVERPORT>/$(echo $SERVERPORT | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g"       |\
sed "s/<NGINX_VOLUME_PATH>/$(echo $NGINX_VOLUME_PATH | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" >> "templates/tmp_docker"
mv -f "templates/tmp_docker" "docker-compose.yml"


cat "templates/nginx_default_footer.conf" >>"templates/tmp_nginx"
mv -f "templates/tmp_nginx" "${NGINX_VOLUME_PATH}/default.conf"

#start container
docker compose up