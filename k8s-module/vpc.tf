data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "k8s-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_subnet" "k8s-subnets" {
  count             = var.availability_zones_count
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet-az-${count.index}"
  }
}

resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_route_table" "k8s-rt" {
  vpc_id = aws_vpc.k8s-vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }

  tags = {
    Name = "k8s-rt"
  }
}

resource "aws_route_table_association" "sub-rt" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.k8s-subnets[count.index].id
  route_table_id = aws_route_table.k8s-rt.id
}