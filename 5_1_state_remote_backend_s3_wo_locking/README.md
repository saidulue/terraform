# Simple VPC with Remote S3 State (No Locking)

Minimal Terraform setup to create a VPC with remote state stored in S3 (without DynamoDB locking).

## 📁 Directory Structure

```
6_Simple_VPC_Remote_State/
├── backend.tf           # S3 backend configuration (separated)
├── provider.tf          # AWS provider only
├── variables.tf         # VPC variables
├── main.tf              # VPC resource only
├── outputs.tf           # VPC outputs
├── terraform.tfvars     # Variable values
├── create-bucket.sh     # Create S3 bucket
└── README.md
```

## 🚀 Quick Start (3 Steps)

### Step 1: Create S3 Bucket

```bash
bash create-bucket.sh

# Output:
# ✓ S3 bucket created
# ✓ Versioning enabled
# ✓ Encryption enabled
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Deploy VPC

```bash
# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
```

## 📋 What Gets Created

✅ **VPC** (10.0.0.0/16)
- DNS enabled
- DNS hostnames enabled

## 🔧 Files Explained

### backend.tf
Separate backend configuration (best practice):
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "my-terraform-state-simple"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # NO dynamodb_table - no locking
  }
}
```

### provider.tf
Only AWS provider (clean and simple):
```hcl
provider "aws" {
  region = var.aws_region
}
```

### main.tf
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}
```

### terraform.tfvars
```hcl
aws_region = "us-east-1"
vpc_cidr   = "10.0.0.0/16"
vpc_name   = "my-vpc"
```

## 🔑 Key Commands

```bash
# Create S3 bucket
bash create-bucket.sh

# Initialize
terraform init

# Plan
terraform plan

# Deploy
terraform apply

# View state
terraform state list
terraform state show aws_vpc.main

# View outputs
terraform output

# Destroy
terraform destroy
```

## 📊 Remote State Info

**State Location:** `s3://my-terraform-state-simple/vpc/terraform.tfstate`

**Features:**
- ✅ Encrypted at rest (AES256)
- ✅ Versioning enabled (rollback capability)
- ✅ Remote storage (shared across machines)
- ❌ NO locking (concurrent applies not prevented)

## ⚠️ Important Notes

1. **No Locking**: Without DynamoDB, multiple users running `terraform apply` simultaneously can cause conflicts
2. **Bucket Name**: Must be globally unique - consider adding account ID: `my-terraform-state-simple-ACCOUNT_ID`
3. **Encryption**: All state files encrypted at rest
4. **Versioning**: Keeps history for rollback

## 🔒 Security

- S3 bucket has encryption enabled (AES256)
- State file contains sensitive data - never commit to Git

## 💰 Cost

Minimal cost:
- S3 bucket: ~$0.023/GB stored
- Estimated: $1-2/month for typical usage

## 🗑️ Cleanup

```bash
# Destroy VPC
terraform destroy

# Delete S3 bucket (if desired)
aws s3 rm s3://my-terraform-state-simple --recursive
aws s3 rb s3://my-terraform-state-simple
```

## Comparison: With vs Without Locking

| Feature | With DynamoDB Lock | Without Lock (This Setup) |
|---------|-------------------|--------------------------|
| Remote State | ✅ S3 | ✅ S3 |
| Encryption | ✅ Yes | ✅ Yes |
| Versioning | ✅ Yes | ✅ Yes |
| Locking | ✅ Prevents concurrent apply | ❌ No protection |
| Cost | ~$2-3/month | ~$1-2/month |
| Team Safe | ✅ Safe for teams | ⚠️ Manual coordination needed |

## 🏗️ Project Structure Best Practices

Having a separate **backend.tf** file provides several benefits:

✅ **Separation of Concerns** - Backend config isolated from provider
✅ **Easier Maintenance** - Find backend config in one place
✅ **Team Friendly** - Clear file organization
✅ **CI/CD Ready** - Easy to override backend config with `-backend-config`
✅ **Reusability** - Copy backend.tf template to other projects

## 📄 File Organization Overview

| File | Purpose | Modifiable |
|------|---------|-----------|
| **backend.tf** | Remote state config | ✅ Rarely (hardcoded values) |
| **provider.tf** | AWS provider settings | ✅ Often (region, tags) |
| **variables.tf** | Input variables | ✅ Often (add new vars) |
| **main.tf** | Resources | ✅ Often (resource changes) |
| **outputs.tf** | Return values | ✅ Often (add outputs) |
| **terraform.tfvars** | Variable values | ✅ Often (change values) |



✅ **Good for:**
- Single developer projects
- Learning Terraform
- Personal labs
- Non-critical environments

❌ **Not recommended for:**
- Team environments
- Production
- CI/CD pipelines
- Multi-user deployments

Use the **locking version** (5_Multi_Env_Remote_State) for production!
