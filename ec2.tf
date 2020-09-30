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
    site_url    = aws_ssm_parameter.site_url.value
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = var.public_key_name
  public_key = file(var.public_key_path)
}

resource "aws_launch_template" "bastion_lt" {
  name          = "bastion_lt"
  description   = "Launch Template for the Bastion instances"
  image_id      = data.aws_ami.amzn_linux_2.id
  instance_type = var.instance_type
  key_name      = var.public_key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion-sg.id]
  }
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                = "bastion-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = aws_subnet.public_subnets[*].id


  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "wordpress_lt" {
  name          = "wordpress_lt"
  description   = "Launch Template for the WordPress instances"
  image_id      = data.aws_ami.amzn_linux_2.id
  instance_type = var.instance_type
  key_name      = var.public_key_name
  user_data     = base64encode(templatefile("./scripts/bootstrap-amz-2.sh", local.credentials))

  iam_instance_profile {
    name = aws_iam_instance_profile.parameter_store_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.wordpress-sg.id]
  }
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "wordpress-asg"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  target_group_arns   = [aws_lb_target_group.wordpress_tg.arn]


  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }
}
