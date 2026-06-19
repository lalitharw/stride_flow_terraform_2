resource "aws_vpc" "stride_flow_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "stride-flow-vpc"
  }
}

# public subnets for alb
resource "aws_subnet" "stride_flow_public_subnet" {
  vpc_id                  = aws_vpc.stride_flow_vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "stride-flow-public-subnet-${count.index + 1}"
  }
}


# internet gateway
resource "aws_internet_gateway" "stride_flow_internet_gateway" {
  vpc_id = aws_vpc.stride_flow_vpc.id

  tags = {
    Name = "stride-flow-internet-gateway"
  }
}

# route table
resource "aws_route_table" "stride_flow_public_route_table" {
  vpc_id = aws_vpc.stride_flow_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stride_flow_internet_gateway.id
  }


  tags = {
    Name = "stride-flow-public-route-table"
  }
}


# route table assocation
resource "aws_route_table_association" "stride_flow_route_table_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.stride_flow_public_subnet[count.index].id
  route_table_id = aws_route_table.stride_flow_public_route_table.id
}


# private subnets
resource "aws_subnet" "stride_flow_private_subnet" {
  vpc_id                  = aws_vpc.stride_flow_vpc.id
  count                   = length(var.private_subnets)
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "stride-flow-private-subnet-${count.index + 1}"
  }
}

# eip
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "stride-flow-nat-eip"
  }
}


# nat gateway
resource "aws_nat_gateway" "stride_flow_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.stride_flow_public_subnet[0].id

  tags = {
    Name = "stride-flow-nat-gateway"
  }


  depends_on = [aws_internet_gateway.stride_flow_internet_gateway]
}


# private route table
resource "aws_route_table" "stride_flow_private_route_table" {
  vpc_id = aws_vpc.stride_flow_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.stride_flow_nat_gateway.id
  }
  tags = {
    Name = "stride-flow-private-route-table"
  }
}

# private table associate
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.stride_flow_private_subnet)
  subnet_id      = aws_subnet.stride_flow_private_subnet[count.index].id
  route_table_id = aws_route_table.stride_flow_private_route_table.id
}


# redis subnet
resource "aws_subnet" "stride_flow_redis_subnet" {
  vpc_id                  = aws_vpc.stride_flow_vpc.id
  cidr_block              = var.redis_subnet
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "stride-flow-redis-subnet"
  }
}

# redis route table
resource "aws_route_table" "stride_flow_redis_route_table" {
  vpc_id = aws_vpc.stride_flow_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.stride_flow_nat_gateway.id
  }
  tags = {
    Name = "stride-flow-redis-route-table"
  }
}

# redis table associate
resource "aws_route_table_association" "redis_route_table_association" {
  subnet_id      = aws_subnet.stride_flow_redis_subnet.id
  route_table_id = aws_route_table.stride_flow_redis_route_table.id
}






