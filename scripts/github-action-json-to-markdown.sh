#!/usr/bin/env bash

ENDPOINTS=$(grep -v '^#' api-endpoints.txt | xargs -d '\n')

for endpoint in $ENDPOINTS
do 
  widdershins ../swagger-definitions/${endpoint}.json --language_tabs shell:Shell http:HTTP javascript:JS php:PHP csharp:C# java:Java -o ../swagger-definitions/${endpoint}.md
done