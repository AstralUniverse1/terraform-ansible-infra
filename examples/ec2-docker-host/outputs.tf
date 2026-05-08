output "instance_id" {
  description = "ID of the EC2 Docker host."
  value       = module.public_ec2_host.instance_id
}

output "public_ip" {
  description = "Public IP address used by Ansible and the HTTP smoke test."
  value       = module.public_ec2_host.public_ip
}

output "ssh_user" {
  description = "Default SSH user for Amazon Linux 2023."
  value       = module.public_ec2_host.ssh_user
}

output "app_url" {
  description = "HTTP URL for the demo service configured by Ansible."
  value       = "http://${module.public_ec2_host.public_ip}:${var.app_port}"
}

output "state_cleanup_hint" {
  description = "Reminder that this stack is isolated in its own backend state key."
  value       = "Destroy this stack from examples/ec2-docker-host with the same backend key used during init."
}
