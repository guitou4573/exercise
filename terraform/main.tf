# This file contains shared data / resources required by the project

data "aws_caller_identity" "current" {}

# Main VPC providing networking space for our VM
module "exercise_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "exercise-vpc"
  # the ranges used here are just an example taken from the module's documentation
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  # I would ideally use a range allocated from VPC IPAM and size the range based on planned capacity.
  cidr = "10.0.0.0/16"

  azs             = var.availability_zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}
