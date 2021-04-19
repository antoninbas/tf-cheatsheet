terraform {
  required_providers {
    aws = {
      version = ">= 3"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "all" {
  state = "available"
}

data "aws_ec2_instance_type_offerings" "offering" {
  for_each = toset(data.aws_availability_zones.all.names)

  filter {
    name   = "instance-type"
    values = ["a1.medium"]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"
}

locals {
  supported-azs = keys({ for az, details in data.aws_ec2_instance_type_offerings.offering : az => details.instance_types if length(details.instance_types) != 0 })
}

resource "aws_key_pair" "my-key" {
  key_name   = "test-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "test-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
}

resource "aws_subnet" "test-subnet" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = "true"
  availability_zone       = local.supported-azs[0]
}

resource "aws_internet_gateway" "test-gw" {
  vpc_id = aws_vpc.test-vpc.id
}

resource "aws_default_route_table" "test-rt" {
  default_route_table_id = aws_vpc.test-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-gw.id
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.test-vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu-arm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*focal*arm64*server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu-amd64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*focal*amd64*server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test-arm" {
  ami           = data.aws_ami.ubuntu-arm.id
  instance_type = "a1.medium"
  subnet_id     = aws_subnet.test-subnet.id
  key_name      = aws_key_pair.my-key.key_name

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Test-ARM"
  }
}

resource "aws_instance" "test-amd64" {
  count         = 2
  ami           = data.aws_ami.ubuntu-amd64.id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.test-subnet.id
  key_name      = aws_key_pair.my-key.key_name

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Test-AMD64-${count.index}"
  }
}

resource "aws_instance" "test-windows" {
  ami           = lookup(var.windows-ami, var.region)
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.test-subnet.id
  key_name      = aws_key_pair.my-key.key_name

  tags = {
    Name = "Test-Windows"
  }
}
