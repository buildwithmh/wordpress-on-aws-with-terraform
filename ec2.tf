data "aws_ami" "amzn_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.amzn_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ssh_and_http.id]
}
