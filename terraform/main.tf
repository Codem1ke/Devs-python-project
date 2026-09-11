terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the latest Ubuntu 24.04 LTS AMI in us-west-2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a key pair using the public SSH key already on your Mac
resource "aws_key_pair" "devops_key" {
  key_name   = "devops-project-key"
  public_key = file(pathexpand("~/.ssh/devs-python-project.pub"))
}

# Security group for our EC2 server
resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  description = "Security group for DevOps project"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask application
  ingress {
    description = "Flask app"
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # CI/CD Flask application
  ingress {
    description = "CI/CD Flask app"
    from_port   = 8087
    to_port     = 8087
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-project-sg"
  }
}
# Create the EC2 server
resource "aws_instance" "devops_server" {
  # Use the latest Ubuntu 24.04 LTS AMI we found above
  ami = data.aws_ami.ubuntu.id

  # Small instance suitable for this learning project
  instance_type = "t3.micro"

  # Put the SSH key on the EC2 server
  key_name = aws_key_pair.devops_key.key_name

  # Attach our security group
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # Give the instance a public IP address
  associate_public_ip_address = true

  # Root storage
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "devops-python-server"
  }
}
