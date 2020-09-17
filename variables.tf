variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sg_ports" {
  type = list(number)
}
