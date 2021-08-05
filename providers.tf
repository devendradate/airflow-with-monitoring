# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 3.36.0"
#     }
#   }
#   }

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  profile = var.profile
}
