
provider "aws" {
    region = var.region_primary
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

resource "aws_vpc" "app_vpc" {
  count = var.create_test_vm ? 1 : 0
  cidr_block           = var.application_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-${random_string.suffix.result}"
  }
  depends_on = [ rediscloud_subscription.rec_subscription ]
}

resource "aws_internet_gateway" "app_igw" {
  count = var.create_test_vm ? 1 : 0
  vpc_id = aws_vpc.app_vpc[0].id
  tags = {
    Name = "${var.prefix}-${random_string.suffix.result}"
  }
}

resource "aws_subnet" "app_subnet" {
  count = var.create_test_vm ? 1 : 0
  vpc_id            = aws_vpc.app_vpc[0].id
  cidr_block        = var.application_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.prefix}-${random_string.suffix.result}"
  }
}

resource "aws_route_table" "my_public_rt" {
  count = var.create_test_vm ? 1 : 0
  vpc_id = aws_vpc.app_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw[0].id
  }

  tags = {
    Name = "${var.prefix}-${random_string.suffix.result}"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = var.create_test_vm ? 1 : 0
  subnet_id      = aws_subnet.app_subnet[0].id
  route_table_id = aws_route_table.my_public_rt[0].id
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
  count = var.create_test_vm ? 1 : 0
  name   = "${var.prefix}-${random_string.suffix.result}"
  vpc_id = aws_vpc.app_vpc[0].id

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
  count = var.create_test_vm ? 1 : 0
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.test_vm_type
  key_name                    = var.key_pair_name
  availability_zone           = aws_subnet.app_subnet[0].availability_zone
  subnet_id                   = aws_subnet.app_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.vm_security_group[0].id]
  associate_public_ip_address = true

  # Install Redis cli and memtier-benchmark
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y lsb-release curl gpg
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    sudo apt-get update -y
    sudo apt-get install -y memtier-benchmark redis-tools
    EOF

  tags = {
    Name = "${var.prefix}-${random_string.suffix.result}"
  }
}

resource "rediscloud_subscription_peering" "peering" {
   count = var.create_test_vm ? 1 : 0
   subscription_id = rediscloud_subscription.rec_subscription.id
   region = var.region_primary
   vpc_id = aws_vpc.app_vpc[0].id
   vpc_cidr = aws_vpc.app_vpc[0].cidr_block
   aws_account_id = var.aws_account_id
   depends_on = [ rediscloud_subscription.rec_subscription, aws_vpc.app_vpc ]
}

resource "aws_vpc_peering_connection_accepter" "peering_acceptor" {
  count = var.create_test_vm ? 1 : 0
  vpc_peering_connection_id = rediscloud_subscription_peering.peering[0].aws_peering_id
  auto_accept               = true
}

resource "aws_route" "route_to_peer_vpc" {
  count = var.create_test_vm ? 1 : 0
  route_table_id            = aws_route_table.my_public_rt[0].id
  destination_cidr_block    = var.deployment_cidr_primary             
  vpc_peering_connection_id = rediscloud_subscription_peering.peering[0].aws_peering_id
  depends_on = [aws_vpc_peering_connection_accepter.peering_acceptor, aws_vpc.app_vpc, aws_route_table.my_public_rt]
}
