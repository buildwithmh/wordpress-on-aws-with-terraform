resource "aws_vpc" "wordpress_vpc" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "wordpress-vpc"
    env  = var.env
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress-i-gw"
    env  = var.env
  }
}

resource "aws_eip" "eip" {
  vpc        = true
  count      = 2
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = format("%s-nat-gw", local.azs[count.index])
    Env  = var.env
  }
}

resource "aws_security_group" "ssh_and_http_sg" {
  name        = "ssh-http-sg"
  description = "Allow SHH & HTTP traffic from any source to the instance"
  vpc_id      = aws_vpc.wordpress_vpc.id

  dynamic "ingress" {
    for_each = var.sg_ingress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
