data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_agent" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.agent.arn,
      "${aws_cloudwatch_log_group.agent.arn}:*",
    ]
  }
}

locals {
  name = "${var.name_prefix}-ec2-cloudwatch-agent"

  selected_az = coalesce(var.availability_zone, data.aws_availability_zones.available.names[0])

  common_tags = merge(var.tags, {
    Project     = var.name_prefix
    Example     = "ec2-cloudwatch-agent"
    ManagedBy   = "terraform"
    Provisioner = "github-actions"
  })
}

resource "aws_cloudwatch_log_group" "agent" {
  name              = "/${var.name_prefix}/ec2-cloudwatch-agent"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_iam_role" "cloudwatch_agent" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_iam_role_policy" "cloudwatch_agent" {
  name   = "${local.name}-logs"
  role   = aws_iam_role.cloudwatch_agent.id
  policy = data.aws_iam_policy_document.cloudwatch_agent.json
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name = local.name
  role = aws_iam_role.cloudwatch_agent.name

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

module "public_ec2_host" {
  source = "../../modules/public-ec2-host"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  availability_zone    = local.selected_az
  instance_type        = var.instance_type
  ssh_public_key       = var.ssh_public_key
  ssh_allowed_cidr     = var.ssh_allowed_cidr
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_agent.name
  tags                 = local.common_tags
}
