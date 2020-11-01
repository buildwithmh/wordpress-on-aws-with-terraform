# (🚧 WIP) A Highly Available Wordpress infrastucture on AWS with Terraform  #

This project was inspired from [Hosting WordPress on AWS](https://github.com/aws-samples/aws-refarch-wordpress) as a menas of applying some of the study material for both the AWS Soultion Architect Associate exam and HashiCorp Certified Terraform Associate.

## Architecture Diagram ##

![alt architecture diagram](https://github.com/MohamedHajr/wordpress-on-aws-with-terraform/blob/master/assets/architecture.jpeg?raw=true))
## Objective ##
- Automating infrastructure provisioning on AWS using Terraform for the following services
  - Amazon Virtual Private Cloud (VPC)
  - Internet Gateway (IGW)
  - NAT Gateway (across all public subnets)
  - Amazon VPC subnets (public, private (data, web)) in all the Availability Zones (AZs) selected
  - Routing tables for public subnets - routing through IGW
  - Routing tables for private subnets - routing through NAT Gateway
  - Mulitple VPC Security Groups
  - Bastion Auto Scaling Group (launching no instances) - in public subnets (public)
  - Amazon Relational Database Service (Amazon RDS) Aurora cluster - in private subnets (data)
  - Amazon Elastic File System (Amazon EFS) file system - with mount targets in private subnets (data)
  - Amazon ElastiCache cache cluster (optional) - in private subnets (data)
  - Wordpress Auto Scaling Group (launching 2 instances) - in private subnets (web)
  - Amazon CloudFront distribution (optional)
  - Amazon Route53 DNS record set (optional)

- LEMP stack and WordPress installation and configuration on EC2

## Requirments to Run This Project ##
- **Terraform** if you don't have it already you can [Download it here](https://www.terraform.io/downloads.html)
- **AWS CLI** if you don't have it configured you find the steps to [install then configure it here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html), also if you wish to use another profile than the default one, you will simply need to change the `profile` parameter in `provider.tf`

## Parameters ##
🚧 WIP
## Steps to Run ##
🚧 WIP
