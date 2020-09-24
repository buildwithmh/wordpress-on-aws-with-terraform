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

locals {
  credentials = {
    db_name     = aws_ssm_parameter.db_name.value
    db_username = aws_ssm_parameter.db_username.value
    db_password = aws_ssm_parameter.db_password.value
    wp_title    = aws_ssm_parameter.wp_title.value
    wp_username = aws_ssm_parameter.wp_username.value
    wp_password = aws_ssm_parameter.wp_password.value
    wp_email    = aws_ssm_parameter.wp_email.value
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = var.public_key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "bastion" {
  count                       = 2
  ami                         = data.aws_ami.amzn_linux_2.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ssh_and_http_sg.id]
  key_name                    = var.public_key_name
  iam_instance_profile        = aws_iam_instance_profile.parameter_store_profile.name
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  associate_public_ip_address = true

  tags = {
    Name = "bastion-${count.index}"
  }
}

resource "aws_instance" "wordpress" {
  count                       = 2
  ami                         = data.aws_ami.amzn_linux_2.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ssh_and_http_sg.id]
  key_name                    = var.public_key_name
  iam_instance_profile        = aws_iam_instance_profile.parameter_store_profile.name
  subnet_id                   = aws_subnet.private_subnet[count.index].id
  associate_public_ip_address = true
  user_data                   = templatefile("./bootstrap-amz-2.sh", local.credentials)

  tags = {
    Name = "bastion-${count.index}"
  }
}

