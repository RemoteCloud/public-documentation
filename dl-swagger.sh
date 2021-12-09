#!/usr/bin/env bash

RESTORE_COLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
LIGHTGRAY='\033[00;37m'
CYAN='\033[00;36m'

# Changing or modifying the endpoints also requires modifications in GitHub Actions and MKDocs API folder.
ENDPOINTS="
    usermanagement_service 
    usermanagement_oauth 
    documentation 
    flows 
    templates 
    pdf-generator 
    notifications 
    remote-execution"

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

mkdir -p ${dl_path}

for endpoint in $ENDPOINTS
do
  wget -O ${dl_path}/${endpoint}.json "${url}${endpoint}"
done