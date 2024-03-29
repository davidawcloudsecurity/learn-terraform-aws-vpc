terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "terraform-default-vpc" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "learn-terraform-vpc"
  }
}

# How to create public / private subnet
resource "aws_subnet" "terraform-public-subnet" {
  vpc_id            = aws_vpc.terraform-default-vpc.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "terraform-public-subnet-A"
  }
}

resource "aws_subnet" "terraform-private-subnet" {
  vpc_id            = aws_vpc.terraform-default-vpc.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "terrform-private-subnet-A"
  }
}

# How to create custom route table
resource "aws_route_table" "terraform-public-route-table" {
  vpc_id = aws_vpc.terraform-default-vpc.id
  route {
    cidr_block = "0.0.0.0/16"
    gateway_id = aws_internet_gateway.terraform-default-igw.id
  }
  tags = {
    Name = "terraform-public-route-table"
  }
}

resource "aws_route_table" "terraform-private-route-table" {
  vpc_id = aws_vpc.terraform-default-vpc.id

# Comment this out to cut cost and focus on igw only
/*
  route {
    cidr_block = "0.0.0.0/16"
    gateway_id = aws_nat_gateway.terraform-ngw.id
  }
*/
  tags = {
    Name = "terraform-private-route-table"
  }
}


# How to create internet gateway
resource "aws_internet_gateway" "terraform-default-igw" {
  vpc_id = aws_vpc.terraform-default-vpc.id

  tags = {
    Name = "terraform-igw"
  }
}

# How to associate route table with specific subnet
resource "aws_route_table_association" "public-subnet-rt-association" {
  subnet_id      = aws_subnet.terraform-public-subnet.id
  route_table_id = aws_route_table.terraform-public-route-table.id
}

resource "aws_route_table_association" "private-subnet-rt-association" {
  subnet_id      = aws_subnet.terraform-private-subnet.id
  route_table_id = aws_route_table.terraform-private-route-table.id
}

# Comment this out to cut cost and focus on igw only
/*
resource "aws_eip" "terraform-nat-eip" {
  vpc = true
   tags = {
      Name = "terraform-nat-eip"
      }
}

resource "aws_nat_gateway" "terraform-ngw" {
  allocation_id = aws_eip.terraform-nat-eip.id
  subnet_id     = aws_subnet.terraform-public-subnet.id
  tags = {
      Name = "terraform-nat-gateway"
      }
}
*/
