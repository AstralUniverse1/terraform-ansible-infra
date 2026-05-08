provider "aws" {
  region = var.aws_region
}

data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "iam_user" {
  source      = "./modules/iam-user"
  user_name   = var.iam_user_name
  policy_arns = var.iam_user_policy_arns
}

module "ec2" {
  source        = "./modules/ec2"
  ami_id        = coalesce(var.ami_id, data.aws_ssm_parameter.al2023_x86_64.value)
  instance_type = var.instance_type
  sg_ids        = [module.sg.sg_id]
  key_name      = var.key_name
  subnet_id     = module.vpc.subnet_id
}

module "sg" {
  source        = "./modules/sg"
  sg_name       = var.sg_name
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  az          = var.az
}

# To run with secure ssh:
# terraform apply -var='ssh_cidr=["<YOUR_CIDR_BLOCK>"]'
