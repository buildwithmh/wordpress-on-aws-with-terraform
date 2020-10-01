#Global Variables
variable "env" {
  type        = string
  description = "current enviroment pod, dev etc.."
}

#EC2 Variables
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "public_key_name" {
  type        = string
  description = "SSH public key name for the AWS key pair"
}

variable "public_key_path" {
  type        = string
  description = "The path on the local machine for the SSH public key"
}

variable "sg_ingress_ports" {
  type        = list(number)
  description = "inbound Security group ports to be opened"
}


variable "wp_admin_email" {
  type        = string
  description = "Wordpress Admin email address"
}


#RDS Variables
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

