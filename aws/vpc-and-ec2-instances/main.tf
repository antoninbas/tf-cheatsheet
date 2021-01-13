provider "aws" {
  version = ">= 3"
  region  = var.region
}

data "aws_availability_zones" "all" {
  state = "available"
}

data "aws_ec2_instance_type_offerings" "offering" {
  for_each = toset(data.aws_availability_zones.all.names)

  filter {
    name   = "instance-type"
    values = [var.instance_type]
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
  key_name   = "antrea-arm-key"
  public_key =  file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "antrea-arm-vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
}

resource "aws_subnet" "antrea-arm-subnet" {
  vpc_id                  = aws_vpc.antrea-arm-vpc.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = "true"
  availability_zone = local.supported-azs[0]
}

resource "aws_internet_gateway" "antrea-arm-gw" {
  vpc_id = aws_vpc.antrea-arm-vpc.id
}

resource "aws_default_route_table" "antrea-arm-rt" {
  default_route_table_id = aws_vpc.antrea-arm-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.antrea-arm-gw.id
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.antrea-arm-vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "antrea-arm" {
  count         = var.instance_count
  ami           = lookup(var.ami,var.region)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.antrea-arm-subnet.id
  key_name      = aws_key_pair.my-key.key_name

  provisioner "remote-exec" {
    connection {
            type     = "ssh"
            user     = "ec2-user"
            private_key = file("~/.ssh/id_rsa")
            host = self.public_ip
    }

    inline = [
      "sudo yum install git docker -y; sudo service docker start; sudo usermod -a -G docker ec2-user"
    ]
  }
}
