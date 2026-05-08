variable "aws_region" {
  description = "AWS region where the EC2 CloudWatch Agent stack is created."
  type        = string
  default     = "il-central-1"
}

variable "name_prefix" {
  description = "Name prefix used for resources in this example stack."
  type        = string
  default     = "terraform-ansible-infra"
}

variable "vpc_cidr" {
  description = "CIDR block for the example VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet. When null, the first available AZ in the region is used."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type for the CloudWatch Agent host."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "Public SSH key material used to create a temporary EC2 key pair."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to the instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "log_retention_days" {
  description = "Retention period for the demo CloudWatch log group."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Extra tags to apply to resources."
  type        = map(string)
  default     = {}
}
