provider "aws" {
    region = var.region_primary
}

# Data source for existing VPC
data "aws_vpc" "application_vpc" {
    filter {
        name   = "tag:Name"
        values = [var.application_vpc] 
    }
}

data "aws_subnet" "application_subnet" {
  filter {
    name   = "tag:Name"
    values = [var.application_subnet] 
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.application_vpc.id]
  }
}


data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "vm_security_group" {
  name   = "${var.prefix}-vm-sg-${random_string.suffix.result}"
  vpc_id = data.aws_vpc.application_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_vm" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.test_vm_type
  key_name                    = var.key_pair_name
  availability_zone           = data.aws_subnet.application_subnet.availability_zone
  subnet_id                   = data.aws_subnet.application_subnet.id
  vpc_security_group_ids      = [aws_security_group.vm_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.prefix}-test-vm"
  }
}