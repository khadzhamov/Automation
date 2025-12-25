terraform {
  backend "s3" {
    bucket         = "aws-tfstate-bucket-backend-0"
    key            = "eu-north-1/sg/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "aws-terraform-state-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.56.0"
    }
  }
  required_version = ">= 1.0.2"
}


provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "Environment"     = "Development",
      "Team"            = "DevOps",
      "DeployedBy"      = "Terraform",
      "OwnerEmail"      = "y.khadzhamov@gmail.com",
      "Type"            = "Security Group"

    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "aws-tfstate-bucket-backend-0"
    key    = "eu-north-1/vpc/terraform.tfstate"
    region = "eu-north-1"
  }
}

resource "aws_security_group" "sg" {
  name        = "bastion-host-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    description = "SSH"
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
  tags = {
    Name = "Bastion-host-SG-SSH"
  }
}