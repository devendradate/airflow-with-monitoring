# vpc data
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

