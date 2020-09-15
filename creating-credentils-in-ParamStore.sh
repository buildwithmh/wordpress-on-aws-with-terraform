#!/bin/bash
website='hajr.io'
evn="dev"
region="eu-west-3"

shopt -s expand_aliases
alias rand=$(openssl rand -base64 16)

#Keys 
db_host="/$website/$env/db-server/host"
db_name="/$website/$env/db-server/name"
db_username="/$website/$env/db-server/username"
db_password="/$website/$env/db-server/password"


aws ssm put-parameter \
    --name $db_name \
    --value `rand` \
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

