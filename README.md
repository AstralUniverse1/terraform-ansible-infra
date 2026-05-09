# Terraform Ansible Infra

Manual GitHub Actions workflows for creating small AWS infrastructure stacks with Terraform and configuring the created hosts with Ansible.

The repo includes a reusable public-host platform module, separate example stacks with separate remote-state keys, and Ansible inventories generated from Terraform outputs.

## Repository Structure

| Path | Purpose |
| --- | --- |
| `.github/workflows/` | Manual GitHub Actions workflows |
| `bootstrap/remote-state/` | Shared S3 + DynamoDB Terraform backend |
| `examples/backend-smoke/` | Remote-state smoke test |
| `examples/ec2-docker-host/` | Public EC2 host configured with Docker and Compose |
| `examples/ec2-cloudwatch-agent/` | Public EC2 host configured with CloudWatch Agent |
| `modules/public-ec2-host/` | Reusable AWS platform module for the EC2 examples |
| `ansible/playbooks/` | Host configuration playbooks |

## Workflows

All workflows are manual (`workflow_dispatch`).

| Workflow | Terraform | Ansible | Verification |
| --- | --- | --- | --- |
| `Bootstrap Remote State` | Creates the shared S3 backend bucket and DynamoDB lock table. | Not used. | Runs a small stack that writes state to the backend. |
| `EC2 Docker Host` | Creates a public Amazon Linux 2023 host from the shared module. | Installs Docker, Docker Compose, and starts an NGINX demo container. | Checks the instance HTTP endpoint. |
| `EC2 CloudWatch Agent` | Creates a public Amazon Linux 2023 host, CloudWatch log group, and IAM permissions. | Installs and configures the CloudWatch Agent. | Writes a marker log line and confirms it arrived in CloudWatch Logs. |

The EC2 workflows generate temporary Ansible inventory from Terraform outputs, so no static inventory file is stored in the repo.

## Shared Terraform Module

`modules/public-ec2-host` is the shared Terraform module used by the EC2 examples.

It provisions the base AWS platform for a public EC2 host:

- VPC
- public subnet
- Internet Gateway and route table
- security group
- EC2 key pair
- Amazon Linux 2023 instance
- encrypted `gp3` root volume

The example stacks can extend it with extra ingress rules and an IAM instance profile.

## SSH Access Model

The EC2 workflows do not rely on a stored SSH private key.

For each run, the workflow generates a temporary ED25519 key pair, detects the GitHub Actions runner public IP, and allows SSH only from that runner `/32`.

The Docker example also opens HTTP port `80` for the demo service.

## Required GitHub secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

The AWS identity needs permissions for S3, DynamoDB, EC2/VPC, IAM, CloudWatch Logs, and SSM Parameter Store AMI lookup.

The EC2 examples create real AWS resources. Destroy the example stack when done testing.
