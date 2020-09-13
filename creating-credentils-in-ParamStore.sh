#!/bin/bash

shopt -s expand_aliases
alias rand='openssl rand -base64 16'


evn="dev"
region="eu-west-3"

#Keys 
db_host="/hajr.io/$env/db-server/host"
db_name="/hajr.io/$env/db-server/name"
db_username="/hajr.io/$env/db-server/username"
db_password="/hajr.io/$env/db-server/password"


aws ssm put-parameter \
    --name $db_name \
    --value "wp_db" \
    --type String \
    --tags "Key=env,Value=$env" \
    --region $region

aws ssm put-parameter \
    --name $db_username \
    --value `rand` \
    --type String \
    --tags "Key=env,Value=$env" \
    --region $region

aws ssm put-parameter \
    --name $db_password \
    --value `rand` \
    --type SecureString \
    --tags "Key=env,Value=$env" \
    --region $region

