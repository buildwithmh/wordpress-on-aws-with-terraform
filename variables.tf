variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sg_ingress_ports" {
  type        = list(number)
  description = "inbound Security group ports to be opened"
}

variable "public_key_name" {
  type        = string
  description = "SSH public key name for the AWS key pair"
}

variable "public_key_path" {
  type        = string
  description = "The path on the local machine for the SSH public key"
}

variable "wp_admin_email" {
  type        = string
  description = "Wordpress Admin email address"
}

variable "env" {
  type        = string
  description = "current enviroment pod, dev etc.."
}
