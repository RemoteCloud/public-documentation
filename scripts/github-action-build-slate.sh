#!/usr/bin/env bash

ENDPOINTS=$(grep -v '^#' api-endpoints.txt | xargs -d '\n')

cd ../slate

for endpoint in $ENDPOINTS
do 
  cp ../swagger-definitions/${endpoint}.md ../slate/source/index.html.md 
  bundle exec middleman build --clean --build-dir ../mkdocs/docs/api/${endpoint}
done