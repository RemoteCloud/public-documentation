#!/usr/bin/env bash

RESTORE_COLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
LIGHTGRAY='\033[00;37m'
CYAN='\033[00;36m'

ENDPOINTS=$(grep -v '^#' api-endpoints.txt | xargs -d '\n')
    
for endpoint in $ENDPOINTS 
do 
  widdershins ./swagger-definitions/${endpoint}.json --language_tabs shell:Shell http:HTTP javascript:JS php:PHP csharp:C# java:Java -o ./swagger-definitions/${endpoint}.md
done

cd slate

for endpoint in $ENDPOINTS
do   
  cp ../swagger-definitions/${endpoint}.md ../slate/source/index.html.md
  bundle exec middleman build --clean --build-dir ../mkdocs/docs/api/${endpoint}
done