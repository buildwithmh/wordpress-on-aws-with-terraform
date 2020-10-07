######################
## Global Variables #######
#####################

variable "env" {
  type        = string
  description = "current enviroment pod, dev etc.."
}

variable "region" {
  type        = string
  description = "AWS Region to use"
  default     = "us-east-1"
}

variable "wp_admin_email" {
  type        = string
  description = "Wordpress Admin email address"
}
######################
## EC2 Variables #######
#####################
variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_public_key_name" {
  type        = string
  description = "SSH public key name for the AWS key pair"
}

variable "ec2_public_key_path" {
  type        = string
  description = "The path on the local machine for the SSH public key"
}

variable "ec2_sg_ingress_ports" {
  type        = list(number)
  description = "inbound Security group ports to be opened"
}

variable "ec2_bastion_asg_desired_capacity" {
  type        = number
  description = "the desired capacity for the bastion instacnes in the auto scaling group"
}

variable "ec2_bastion_asg_min_capacity" {
  type        = number
  description = "the minimum capacity for the bastion instacnes in the auto scaling group"
}

variable "ec2_bastion_asg_max_capacity" {
  type        = number
  description = "the maximum capacity to scale out to, for the bastion instacnes in the auto scaling group"
}

variable "ec2_wordpress_asg_desired_capacity" {
  type        = number
  description = "the desired capacity for the wordpress instacnes in the auto scaling group"
}

variable "ec2_wordpress_asg_min_capacity" {
  type        = number
  description = "the minimum capacity for the wordpress instacnes in the auto scaling group"
}

variable "ec2_wordpress_asg_max_capacity" {
  type        = number
  description = "the maximum capacity to scale out to, for the wordpress instacnes in the auto scaling group"
}

#####################
## RDS Variables #######
#####################

variable "db_instance_type" {
  type        = string
  description = "The DB instance class type db.t2.micro, db.m5.larage, etc.."
}

variable "db_storage_capacity" {
  type        = number
  description = "Allocated storage capacity for the RDS instance"
}

variable "db_storage_type" {
  type        = string
  description = "The Strorage type of the DB instance gp2, io1 , etc..."
}

variable "db_engine" {
  type        = string
  description = "The type of engine to run on the DB instance aurora, mysql, postgresql, etc.."
}

variable "db_engine_version" {
  type        = string
  description = "The version of the engine running on the DB instance"
}

variable "db_port" {
  type        = number
  description = "The port that the DB engine listening on"
}

############################
## Elastic Cache Variables #######
############################
variable "ec_node_type" {
  type        = string
  description = "The instance type for each node in the cluster"
}

variable "ec_nodes_count" {
  type        = number
  description = "Number of nodes in the cluster if az_mode is cross-az this must be more than 1"
}

variable "ec_az_mode" {
  type        = string
  description = "Specifies whether the nodes is going to be created across azs or in a single az"

  validation {
    condition     = var.ec_az_mode == "cross-az" || var.ec_az_mode == "single-az"
    error_message = "The az_mode value can only be 'cross-az' or 'single-az'."
  }
}

variable "ec_memcached_port" {
  type        = number
  description = "The Memcache port that the nodes will be listing on"
}
