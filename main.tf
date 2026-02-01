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

resource "aws_instance" "instance1" {
  ami           = "ami-0b6c6ebed2801a5cb" # Replace with your AMI
  instance_type = "t3.medium"
  key_name      = "mern-sai"

  # Pick the first public subnet (or choose based on AZ)
  subnet_id = data.aws_subnets.public.ids[0]

  # Security group
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  associate_public_ip_address = true # Needed for public subnet

  user_data = file("./userdata-master.sh")
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
  ami           = "ami-0b6c6ebed2801a5cb" # Replace with your AMI
  instance_type = "t3.medium"

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


