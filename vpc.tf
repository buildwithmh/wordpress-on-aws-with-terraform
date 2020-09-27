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
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags = {
    Name = format("%s-nat-gw", local.azs[count.index])
    Env  = var.env
  }
}
