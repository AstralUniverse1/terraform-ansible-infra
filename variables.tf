variable "aws_region" {
  type    = string
  default = "il-central-1"
}

variable "ami_id" {
  description = "Optional AMI override. When null, the latest regional Amazon Linux 2023 x86_64 AMI is resolved from SSM."
  type        = string
  default     = null
}

variable "instance_type" {
  type    = string
  default = "t3.micro" # example instance type
}

variable "iam_user_name" {
  type    = string
  default = "example-user" # example IAM user name
}
variable "iam_user_policy_arns" {
  type    = list(string)
  default = [] # add policy ARNs here or at apply
}

variable "sg_name" {
  type    = string
  default = "default_sg" # example security group name
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # open to all by default; override at apply for security
      description = "SSH"
    }
  ]
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "key_name" {
  type    = string
  default = null # add keypair here or in apply
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "az" {
  type    = string
  default = "il-central-1a"
}
