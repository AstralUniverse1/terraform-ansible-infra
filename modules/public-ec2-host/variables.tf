variable "name" {
  description = "Base name used for all public EC2 host resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key material used to create the EC2 key pair."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to the instance."
  type        = string
}

variable "ingress_rules" {
  description = "Additional security group ingress rules."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "iam_instance_profile" {
  description = "Optional IAM instance profile name to attach to the EC2 instance."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 8
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
