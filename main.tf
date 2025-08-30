# Terraform configuration for Nomad testing environment
# This will create 6 EC2 instances with appropriate sizing for Nomad

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source to get the latest CentOS Stream 8 AMI from AWS
data "aws_ami" "centos_stream8" {
  most_recent = true
  owners      = ["125523088429"] # Official CentOS account
  
  filter {
    name   = "name"
    values = ["*CentOS*Stream*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Create a key pair for SSH access
resource "aws_key_pair" "nomad_key" {
  key_name   = "nomad-testing-key"
  public_key = tls_private_key.nomad_private_key.public_key_openssh

  tags = {
    Name        = "Nomad Testing Key"
    Environment = "testing"
    Purpose     = "nomad-cluster"
  }
}

# Generate a private key
resource "tls_private_key" "nomad_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file
resource "local_file" "nomad_private_key_pem" {
  content         = tls_private_key.nomad_private_key.private_key_pem
  filename        = "${path.module}/nomad-testing-key.pem"
  file_permission = "0600"
}
