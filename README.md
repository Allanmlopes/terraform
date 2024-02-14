terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 0.15.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-008fe2fc65df48dac"
  instance_type = "t2.micro"
  key_name = "iac-terraform"
  tags = {
    Name = "Minha Maquina Ubuntu"
  }
}
