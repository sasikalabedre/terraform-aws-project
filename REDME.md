# Terraform AWS Project

A reproducible AWS environment built with Terraform: a VPC with public and
private subnets in two availability zones, route tables, a security group,
an IAM role, and a small nginx web server. State is stored remotely in S3.

## Architecture

See [docs/architecture.md](docs/architecture.md) for the diagram.

## What gets created

| Resource | Count |
|---|---|
| VPC | 1 |
| Public subnets | 2 |
| Private subnets | 2 |
| Internet gateway | 1 |
| Route tables and associations | 2 and 4 |
| Security group (HTTP in, all out) | 1 |
| IAM role, policy attachment, instance profile | 1 each |
| EC2 server running nginx | 1 |

Total: 17 resources. The full list is in [plan.txt](plan.txt).

## Requirements

- Terraform 1.10 or newer
- AWS CLI, configured with `aws configure`
- An AWS account and an IAM user allowed to create the resources above

## Setup

### 1. Create the S3 bucket for Terraform state (one time)

Bucket names are unique worldwide, so choose your own name.

```bash
aws s3api create-bucket \
  --bucket YOUR-STATE-BUCKET \
  --region ap-southeast-2 \
  --create-bucket-configuration LocationConstraint=ap-southeast-2

aws s3api put-bucket-versioning \
  --bucket YOUR-STATE-BUCKET \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket YOUR-STATE-BUCKET \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-encryption \
  --bucket YOUR-STATE-BUCKET \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

### 2. Point the project at your bucket

In `backend.tf`, change `bucket` to YOUR-STATE-BUCKET.

### 3. Initialize

```bash
terraform init
```

## Review and deploy

```bash
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform show -no-color tfplan > plan.txt
```

Read `plan.txt`, then apply exactly the reviewed plan:

```bash
terraform apply tfplan
```

When it finishes, open the `app_url` output in a browser. Wait one to two
minutes after the server starts for nginx to install.

To open a shell on the server without SSH, use EC2, Connect, Session Manager.

## Variables

| Name | Default | Purpose |
|---|---|---|
| `region` | `ap-southeast-2` | AWS region |
| `project_name` | `tf-aws-project` | Name prefix and tag on every resource |
| `public_subnet_cidrs` | `10.0.1.0/24`, `10.0.2.0/24` | Public subnet ranges |
| `private_subnet_cidrs` | `10.0.11.0/24`, `10.0.12.0/24` | Private subnet ranges |
| `instance_type` | `t3.micro` | EC2 server size |

## Teardown

1. Destroy everything this project created:

   ```bash
   terraform destroy
   ```

   Type `yes` when asked.

2. Check that nothing is left:

   ```bash
   aws ec2 describe-vpcs --region ap-southeast-2 \
     --query 'Vpcs[?IsDefault==`false`].[VpcId,Tags[0].Value]' --output text
   ```

   It should print nothing.

3. Optional: delete the state bucket when you no longer need it. It has
   versioning on, so empty it first, including all versions (the S3 console's
   Empty button does this), then delete the bucket.

## Notes

- No NAT Gateway is created because it is charged every hour. The server runs
  in a public subnet. If servers in the private subnets needed internet
  access, a NAT Gateway and a private route to it would be added.
- No secrets are stored in this repo. State files, `.tfvars` files and plan
  files are excluded by `.gitignore`.
- SSH is not opened. Access is through AWS Systems Manager Session Manager.