data "aws_availability_zones" "azs" {
}

resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.azs.names
  result_count = var.subnet_count
}

resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = random_shuffle.azs.result[count.index]
  map_public_ip_on_launch = true



  tags = merge(var.common_tags,
    {
      Name = "public-subnet-${count.index + 1}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.subnet_count)
  availability_zone = random_shuffle.azs.result[count.index]

  tags = merge(var.common_tags,
    {
      Name = "private-subnet-${count.index + 1}"
    }
  )
}

resource "aws_eip" "nat_gateways" {
  count  = var.nat_gateway_count
  domain = "vpc"
}

resource "aws_nat_gateway" "default" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat_gateways[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = merge(var.common_tags,
    {
      Name = "private-subnet-rt"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = merge(var.common_tags,
    {
      Name = "public-subnet-rt"
    }
  )
}

resource "aws_route" "public_subnet_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route" "private_subnet_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[0].id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
