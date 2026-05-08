variable "aws_region" {
  description = "AWS region for the remote-state backend resources."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid lowercase S3 bucket name."
  }
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
}

variable "environment" {
  description = "Environment label used for resource tags."
  type        = string
  default     = "bootstrap"
}

variable "tags" {
  description = "Additional tags to apply to backend resources."
  type        = map(string)
  default     = {}
}
