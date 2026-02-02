provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket       = "saibucket876"
    key          = "terraform/terraform.tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_route_tables" "public_rt" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_security_group" "sg" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["Allow-all"]

  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = data.aws_subnets.public.ids[0]
  route_table_id = data.aws_route_tables.public_rt.ids[0]
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = data.aws_subnets.public.ids[1]
  route_table_id = data.aws_route_tables.public_rt.ids[0]
}


resource "aws_instance" "instance1" {
  ami                         = "ami-0220d79f3f480ecf5" # Replace with your AMI
  instance_type               = "t3.small"
  key_name                    = "mern-sai"
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.sg.id]
  associate_public_ip_address = true # Needed for public subnet
  user_data                   = file("./userdata-master.sh")
  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Jenkins-Master"
  }
}

resource "aws_instance" "instance2" {
  ami           = "ami-0220d79f3f480ecf5" # Replace with your AMI
  instance_type = "t3.small"

  # Pick the first public subnet (or choose based on AZ)
  subnet_id = data.aws_subnets.public.ids[1]

  # Security group
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  associate_public_ip_address = true # Needed for public subnet
  user_data                   = file("./userdata-slave.sh")

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true

  }


  tags = {
    Name = "Jenkins-slave1"
  }
}


