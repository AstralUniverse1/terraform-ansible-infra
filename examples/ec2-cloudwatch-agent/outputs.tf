output "instance_id" {
  description = "ID of the EC2 CloudWatch Agent host."
  value       = module.public_ec2_host.instance_id
}

output "public_ip" {
  description = "Public IP address used by Ansible."
  value       = module.public_ec2_host.public_ip
}

output "ssh_user" {
  description = "Default SSH user for Amazon Linux 2023."
  value       = module.public_ec2_host.ssh_user
}

output "log_group_name" {
  description = "CloudWatch log group used by the agent."
  value       = aws_cloudwatch_log_group.agent.name
}

output "log_stream_name" {
  description = "CloudWatch log stream name configured by Ansible."
  value       = module.public_ec2_host.instance_id
}

output "state_cleanup_hint" {
  description = "Reminder that this stack is isolated in its own backend state key."
  value       = "Destroy this stack from examples/ec2-cloudwatch-agent with the same backend key used during init."
}
