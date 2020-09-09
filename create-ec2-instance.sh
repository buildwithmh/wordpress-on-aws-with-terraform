#!/bin/bash
#No error handling for simplicty sake

echo "Enter the region: "
read REGION
echo "  "
echo "Enter the key pair name: "
read KEY_PAIR_NAME
echo "Enter AMI Image Id: "
read AMI_ID

#Create the keyPair for ssh
aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --query 'KeyMaterial' --output text > ~/.ssh/$KEY_PAIR_NAME.pem --region $REGION
echo "Key pair created sucessfully and saved to ~/.ssh/$KEY_PAIR_NAME."

chmod 400 ~/.ssh/$KEY_PAIR_NAME.pem

#Assumimg I have only one vpc in that region the default one
VPC_ID=`aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text --region $REGION`
echo "Successfully got the default VPC ID $VPC_ID....."

SG_ID=`aws ec2 create-security-group --group-name ssh-http --description "Allows SSH and HTTP traffic" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION`
echo "Successfully created the security group with Id $SG_ID....."

echo "Allowing SSH & HTTP traffic on $SG_ID......"
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION >> /dev/null
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION >> /dev/null

echo "Launching the instance....."
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro --key-name $KEY_PAIR_NAME --security-group-ids $SG_ID --user-data file://bootstrap.sh --region $REGION 
