#!/bin/bash
#No error handling for simplicty sake

echo "Enter the region: "
read region
echo "  "
echo "Enter the key pair name: "
read key_pair_name
echo "Enter AMI Image Id: "
read ami_id

#Create the keyPair for ssh
aws ec2 create-key-pair --key-name $key_pair_name --query 'KeyMaterial' --output text > ~/.ssh/$key_pair_name.pem --region $region
echo "Key pair created sucessfully and saved to ~/.ssh/$key_pair_name."

chmod 400 ~/.ssh/$key_pair_name.pem

#Assumimg I have only one vpc in that region the default one
vpc_id=`aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text --region $region`
echo "Successfully got the default VPC ID $vpc_id....."

sg_id=`aws ec2 create-security-group --group-name ssh-http --description "Allows SSH and HTTP traffic" --vpc-id $vpc_id --query 'GroupId' --output text --region $region`
echo "Successfully created the security group with Id $sg_id....."

echo "Allowing SSH & HTTP traffic on $sg_id......"
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region >> /dev/null
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region >> /dev/null

#creating IAM role for ec2 to have access to parameter store
aws iam create-role --role-name ps-access --assume-role-policy-document file://policies/trust-policy.json
aws iam put-role-policy --role-name ps-access --policy-name param-store-access-policy --policy-document file://policies/parameter-store-access.json

echo "Launching the instance....."
aws ec2 run-instances --image-id $ami_id --iam-instance-profile Name="ps-access" --count 1 --instance-type t2.micro --key-name $key_pair_name --security-group-ids $sg_id --user-data file://bootstrap.sh --region $region 
