#!/usr/bin/env bash

RESTORE_COLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
LIGHTGRAY='\033[00;37m'
CYAN='\033[00;36m'


echo -e "\n${CYAN}========== Script configuration ===============${RESTORE_COLOR}\n"

echo -ne "Please define the ${GREEN}https://base.url${RESTORE_COLOR} of the API gateway:"
read BaseUrl

echo -ne "Please define the ${GREEN}API version${RESTORE_COLOR}:"
read Version

if [ -z ${BaseUrl} ]; then  
  echo -e "${YELLOW}> API base url is missing!${RESTORE_COLOR}"
  exit 1
fi

if [ -z ${Version} ]; then  
  echo -e "${YELLOW}> API version is missing!${RESTORE_COLOR}"
  exit 1
fi

url="${BaseUrl}/swagger/docs/${Version}/"
dl_path=./swagger-definitions

mkdir ${dl_path}
wget -O ${dl_path}/usermanagement_service.json "${url}usermanagement_service"
wget -O ${dl_path}/usermanagement_oauth.json "${url}usermanagement_oauth"
wget -O ${dl_path}/documentation.json "${url}documentation"
wget -O ${dl_path}/flows.json "${url}flows"
wget -O ${dl_path}/templates.json "${url}templates"
wget -O ${dl_path}/pdf-generator.json "${url}pdf-generator"
wget -O ${dl_path}/notifications.json "${url}notifications"
wget -O ${dl_path}/remote-execution.json "${url}remote-execution"