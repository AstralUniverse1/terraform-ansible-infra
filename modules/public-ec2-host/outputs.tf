output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.this.public_ip
}

output "ssh_user" {
  description = "Default SSH user for Amazon Linux 2023."
  value       = "ec2-user"
}

output "security_group_id" {
  description = "ID of the public host security group."
  value       = aws_security_group.this.id
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}
