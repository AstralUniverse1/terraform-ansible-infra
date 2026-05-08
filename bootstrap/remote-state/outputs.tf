output "state_bucket_name" {
  description = "S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.state.id
}

output "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.locks.name
}

output "aws_region" {
  description = "AWS region containing the backend resources."
  value       = var.aws_region
}

output "backend_config_example" {
  description = "Example backend config values for stacks that use this remote backend."
  value = {
    bucket         = aws_s3_bucket.state.id
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.locks.name
    encrypt        = true
  }
}
