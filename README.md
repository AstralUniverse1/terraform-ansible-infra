# Terraform Ansible Infra

GitHub Actions workflows for building AWS infrastructure with Terraform and configuring EC2 hosts with Ansible.

The project covers a remote Terraform backend, reusable Terraform modules, and Terraform-to-Ansible handoff inside GitHub Actions. The example workflows intentionally use separate Terraform state keys so each stack can be run and cleaned up independently.

The workflows also generate temporary SSH access for each run and derive backend names from the target AWS account.

## Workflows

| Workflow | Purpose |
| --- | --- |
| `Bootstrap Remote State` | Creates or adopts the S3 backend bucket and DynamoDB lock table, then runs a small backend smoke stack. |
| `EC2 Docker Host` | Provisions an EC2 host, runs Ansible to install Docker and Docker Compose, deploys NGINX, and checks HTTP. |
| `EC2 CloudWatch Agent` | Provisions an EC2 host with IAM and CloudWatch Logs, runs Ansible to install the CloudWatch Agent, and checks log delivery. |

## Requirements

The workflows are manual GitHub Actions jobs and expect AWS credentials in repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

The Terraform examples use remote state, so the backend workflow should be run before the EC2 workflows.
