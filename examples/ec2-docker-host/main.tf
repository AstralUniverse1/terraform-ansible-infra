data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.name_prefix}-ec2-docker-host"

  selected_az = coalesce(var.availability_zone, data.aws_availability_zones.available.names[0])

  common_tags = merge(var.tags, {
    Project     = var.name_prefix
    Example     = "ec2-docker-host"
    ManagedBy   = "terraform"
    Provisioner = "github-actions"
  })
}

module "public_ec2_host" {
  source = "../../modules/public-ec2-host"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = local.selected_az
  instance_type      = var.instance_type
  ssh_public_key     = var.ssh_public_key
  ssh_allowed_cidr   = var.ssh_allowed_cidr
  tags               = local.common_tags

  ingress_rules = [
    {
      description = "HTTP demo service"
      from_port   = var.app_port
      to_port     = var.app_port
      protocol    = "tcp"
      cidr_blocks = [var.http_allowed_cidr]
    }
  ]
}
