#!/bin/bash

#Objective
#Create db name, db user, db password, db host
DB_HOST=$1
DB_NAME='hajr.io/dev/db'
DB_USERNAME='hajr.io/dev/admin'
DB_PASSWORD=`openssl rand -base64 16`


echo "Enter Region:"
read REGION

#Create DB Name


