#!/usr/bin/env bash

ENDPOINTS=$(grep -v '^#' api-endpoints.txt | xargs -d '\n')

for endpoint in $ENDPOINTS
do 
  widdershins --language_tabs 'shell:Shell' 'http:HTTP' 'javascript:JS' 'php:PHP' 'csharp:C#' 'java:Java' --summary ../swagger-definitions/${endpoint}.json -o ../swagger-definitions/${endpoint}.md
done