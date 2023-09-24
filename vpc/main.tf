resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags       = var.vpc_tags
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id
  tags   = var.igw_tags 
}

