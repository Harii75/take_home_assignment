provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../modules/vpc"

  name     = "example"
  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    "a" = { cidr_block = "10.0.1.0/24" }
    "b" = { cidr_block = "10.0.2.0/24" }
  }

  private_subnets = {
    "a" = { cidr_block = "10.0.3.0/24" }
    "b" = { cidr_block = "10.0.4.0/24" }
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "load_balancer_sg_id" {
  value = module.vpc.load_balancer_sg_id
}

output "app_server_sg_id" {
  value = module.vpc.app_server_sg_id
}
