data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.azs.names
}

variable "subnets_cidr_blocks" {
  type        = list(string)
  description = "List of cidr blocks for each subnet within the vpc range"
  default     = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26", "10.0.0.192/26"]
}

resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.subnets_cidr_blocks[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = format("%s-public-subnet", local.azs[count.index])
    Env  = var.env
  }
}



resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.subnets_cidr_blocks[count.index + 2]
  availability_zone = local.azs[count.index]

  tags = {
    Name = format("%s-private-subnet", local.azs[count.index])
    Env  = var.env
  }
}

