# Terraform Ansible Infra

Terraform + Ansible workflow examples for AWS infrastructure automation from GitHub Actions.

The repo demonstrates three things:

- bootstrapping a reusable Terraform remote backend
- provisioning short-lived AWS infrastructure with isolated remote state
- passing Terraform outputs into Ansible for configuration and runtime verification

## Workflows

All workflows are manual GitHub Actions workflows.

| Workflow | Purpose |
| --- | --- |
| `Bootstrap Remote State` | Creates/adopts the S3 state bucket and DynamoDB lock table, then writes a smoke state. |
| `EC2 Docker Host` | Provisions a public EC2 host, configures Docker/Compose with Ansible, deploys NGINX, and verifies HTTP. |
| `EC2 CloudWatch Agent` | Provisions a public EC2 host with IAM and CloudWatch Logs, configures the CloudWatch Agent with Ansible, and verifies log ingestion. |

Required GitHub secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Default region:

```text
il-central-1
```

## Backend And State

Shared backend infrastructure:

```text
bucket: terraform-ansible-infra-889966879500-il-central-1-tfstate
lock table: terraform-ansible-infra-il-central-1-tf-locks
region: il-central-1
```

The bucket has versioning, AES256 server-side encryption, and public access block enabled. DynamoDB provides state locking.

State keys:

```text
examples/backend-smoke.tfstate
examples/ec2-docker-host.tfstate
examples/ec2-cloudwatch-agent.tfstate
```

Each workflow owns its own state key. The EC2 workflows share `modules/public-ec2-host` as code, not as live infrastructure.

## Repository Layout

```text
.github/workflows/
  bootstrap-remote-state.yml
  ec2-docker-host.yml
  ec2-cloudwatch-agent.yml

bootstrap/remote-state/
  Backend bootstrap stack.

examples/backend-smoke/
  Minimal remote-state write test.

examples/ec2-docker-host/
  Docker host stack.

examples/ec2-cloudwatch-agent/
  CloudWatch Agent stack.

modules/public-ec2-host/
  Shared public EC2 host module.

ansible/playbooks/
  docker-host.yml
  cloudwatch-agent.yml
```

## Proven Runs

### Bootstrap Remote State

Proven result:

- S3 state bucket created/adopted.
- DynamoDB lock table created/adopted.
- Remote smoke state written successfully.
- Reruns are idempotent through Terraform imports.

### EC2 Docker Host

Proven result:

- Terraform created public EC2 infrastructure.
- The workflow generated an ephemeral SSH key and restricted SSH to the runner IP.
- Ansible installed Docker/Compose and deployed an NGINX Compose service.
- The workflow verified the public HTTP endpoint.
- The stack was destroyed cleanly afterward.

### EC2 CloudWatch Agent

Proven result:

- Terraform created EC2, IAM role/profile/policy, and a CloudWatch log group.
- Ansible installed and configured the Amazon CloudWatch Agent.
- The workflow verified a marker log in CloudWatch Logs.
- The stack was destroyed cleanly afterward.

Verified marker:

```text
log group: /terraform-ansible-infra/ec2-cloudwatch-agent
log stream: i-0c13503cefb2fe430
message: terraform-ansible-cloudwatch-25561588535-1
```

## Running

Run workflows from the GitHub Actions UI.

### Bootstrap Remote State

```text
Actions -> Bootstrap Remote State -> Run workflow
```

Defaults:

```text
aws_region: il-central-1
name_prefix: terraform-ansible-infra
state_key: examples/backend-smoke.tfstate
```

### EC2 Docker Host

```text
Actions -> EC2 Docker Host -> Run workflow
```

Defaults:

```text
aws_region: il-central-1
name_prefix: terraform-ansible-infra
state_key: examples/ec2-docker-host.tfstate
destroy_on_failure: true
```

### EC2 CloudWatch Agent

```text
Actions -> EC2 CloudWatch Agent -> Run workflow
```

Defaults:

```text
aws_region: il-central-1
name_prefix: terraform-ansible-infra
state_key: examples/ec2-cloudwatch-agent.tfstate
destroy_on_failure: true
```

Successful EC2 workflow runs are left running for inspection. Failed runs destroy automatically when `destroy_on_failure` is true.

## Destroy

Destroy from the matching example directory and state key.

Docker host:

```bash
cd examples/ec2-docker-host

tmp_key="/tmp/ec2-docker-host-destroy-key-$(date +%s)"
ssh-keygen -q -t ed25519 -N "" -f "$tmp_key"

AWS_PROFILE=Astral terraform init -reconfigure \
  -backend-config="bucket=terraform-ansible-infra-889966879500-il-central-1-tfstate" \
  -backend-config="key=examples/ec2-docker-host.tfstate" \
  -backend-config="region=il-central-1" \
  -backend-config="dynamodb_table=terraform-ansible-infra-il-central-1-tf-locks" \
  -backend-config="encrypt=true"

AWS_PROFILE=Astral terraform destroy \
  -var="aws_region=il-central-1" \
  -var="name_prefix=terraform-ansible-infra" \
  -var="ssh_allowed_cidr=127.0.0.1/32" \
  -var="ssh_public_key=$(cat ${tmp_key}.pub)"

rm -f "$tmp_key" "${tmp_key}.pub"
```

CloudWatch Agent:

```bash
cd examples/ec2-cloudwatch-agent

tmp_key="/tmp/ec2-cloudwatch-agent-destroy-key-$(date +%s)"
ssh-keygen -q -t ed25519 -N "" -f "$tmp_key"

AWS_PROFILE=Astral terraform init -reconfigure \
  -backend-config="bucket=terraform-ansible-infra-889966879500-il-central-1-tfstate" \
  -backend-config="key=examples/ec2-cloudwatch-agent.tfstate" \
  -backend-config="region=il-central-1" \
  -backend-config="dynamodb_table=terraform-ansible-infra-il-central-1-tf-locks" \
  -backend-config="encrypt=true"

AWS_PROFILE=Astral terraform destroy \
  -var="aws_region=il-central-1" \
  -var="name_prefix=terraform-ansible-infra" \
  -var="ssh_allowed_cidr=127.0.0.1/32" \
  -var="ssh_public_key=$(cat ${tmp_key}.pub)"

rm -f "$tmp_key" "${tmp_key}.pub"
```

## Validation

Use `TF_DATA_DIR` outside the repo to keep local Terraform metadata out of example directories.

```bash
terraform fmt -check -recursive

TF_DATA_DIR=/tmp/tfdata-bootstrap terraform -chdir=bootstrap/remote-state init -backend=false
TF_DATA_DIR=/tmp/tfdata-bootstrap terraform -chdir=bootstrap/remote-state validate

TF_DATA_DIR=/tmp/tfdata-smoke terraform -chdir=examples/backend-smoke init -backend=false
TF_DATA_DIR=/tmp/tfdata-smoke terraform -chdir=examples/backend-smoke validate

TF_DATA_DIR=/tmp/tfdata-docker terraform -chdir=examples/ec2-docker-host init -backend=false
TF_DATA_DIR=/tmp/tfdata-docker terraform -chdir=examples/ec2-docker-host validate

TF_DATA_DIR=/tmp/tfdata-cloudwatch terraform -chdir=examples/ec2-cloudwatch-agent init -backend=false
TF_DATA_DIR=/tmp/tfdata-cloudwatch terraform -chdir=examples/ec2-cloudwatch-agent validate

ansible-playbook --syntax-check ansible/playbooks/docker-host.yml
ansible-playbook --syntax-check ansible/playbooks/cloudwatch-agent.yml
```

## Cost And Security

The EC2 workflows use one `t3.micro` instance, an 8 GB encrypted gp3 root volume, public networking, and no NAT Gateway, load balancer, Elastic IP, RDS, or Route 53 resources. The CloudWatch workflow adds a small log group with 1-day retention.

Current AWS authentication uses long-lived access keys in GitHub Actions secrets. A production version should use GitHub Actions OIDC with an assumable least-privilege IAM role.

The repo does not track Terraform state, tfvars, generated backend config files, secrets, or generated SSH keys.
