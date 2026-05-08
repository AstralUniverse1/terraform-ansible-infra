data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
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

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.selected_az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-public"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "docker_host" {
  name        = local.name
  description = "Allow SSH and HTTP access to the EC2 Docker host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP demo service"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.http_allowed_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_key_pair" "workflow" {
  key_name   = "${local.name}-${data.aws_caller_identity.current.account_id}"
  public_key = var.ssh_public_key

  tags = merge(local.common_tags, {
    Name = "${local.name}-workflow"
  })
}

resource "aws_instance" "docker_host" {
  ami                         = data.aws_ssm_parameter.al2023_x86_64.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.docker_host.id]
  key_name                    = aws_key_pair.workflow.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(local.common_tags, {
    Name = local.name
  })
}
