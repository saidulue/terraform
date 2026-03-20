# Terraform VPC with Remote State Setup

This directory contains Terraform code to create a VPC with a **remote state file** stored in S3 and state locking with DynamoDB.

## Directory Structure

```
4_VPC_Remote_State/
├── provider.tf          # AWS provider + S3 backend config
├── variables.tf         # Input variables
├── main.tf              # VPC resources
├── outputs.tf           # Output values
├── backend_setup.tf     # Setup S3 + DynamoDB (run first)
├── terraform.tfvars     # Variable values
└── README.md
```

## Setup Steps

### Step 1: Create S3 Bucket and DynamoDB Table

First, create the S3 bucket and DynamoDB table to store the remote state:

```bash
# Create a temporary directory for backend setup
mkdir backend-setup
cd backend-setup

# Copy backend_setup.tf to this directory
cp ../backend_setup.tf .

# Initialize and apply
terraform init
terraform apply

# Note the outputs:
# - s3_bucket_name: my-terraform-state-bucket-ACCOUNT_ID
# - dynamodb_table_name: terraform-locks

cd ..
```

### Step 2: Update Backend Configuration

Update `provider.tf` with the actual S3 bucket name from Step 1:

```hcl
backend "s3" {
  bucket         = "my-terraform-state-bucket-123456789"  # Update with actual name
  key            = "vpc/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

### Step 3: Initialize Terraform and Deploy VPC

```bash
# Initialize Terraform with S3 backend
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
```

## What Gets Created

✅ **VPC** (10.0.0.0/16)
✅ **Public Subnet** (10.0.1.0/24)
✅ **Internet Gateway**
✅ **Route Table** with route to IGW
✅ **Route Table Association**
✅ **S3 Bucket** for remote state (versioned, encrypted)
✅ **DynamoDB Table** for state locking

## Remote State Benefits

| Feature | Local State | Remote State |
|---------|------------|--------------|
| **Storage** | Local disk | S3 (safer) |
| **Sharing** | Single user only | Team-friendly |
| **Locking** | No locking | DynamoDB prevents conflicts |
| **Backup** | Manual | S3 versioning |
| **History** | None | Version history |

## Key Files Explained

### provider.tf
- Configures AWS provider
- Defines S3 backend for remote state
- Enables DynamoDB locking

### backend_setup.tf
- Creates S3 bucket with versioning and encryption
- Creates DynamoDB table for state locking
- Must run FIRST in a separate directory

### main.tf
- Creates VPC with DNS enabled
- Creates public subnet
- Creates Internet Gateway
- Creates route table with IGW route

## Commands

```bash
# Initialize with remote backend
terraform init

# Plan VPC changes
terraform plan

# Apply VPC changes
terraform apply

# Shows remote state info
terraform state list

# View specific resource
terraform state show aws_vpc.main

# Pull remote state locally (rarely needed)
terraform state pull

# View outputs
terraform output vpc_id
```

## File Structure After Setup

```
backend-setup/
├── backend_setup.tf
├── terraform.tfstate
├── terraform.tfstate.backup
└── .terraform/

4_VPC_Remote_State/
├── provider.tf              # Has S3 backend config
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.state         # NOT created - stored in S3
├── .terraform/
└── .terraform.lock.hcl
```

## Remote State File Location

- **S3 Path**: `s3://my-terraform-state-bucket-ACCOUNT_ID/vpc/terraform.tfstate`
- **State Lock**: DynamoDB table `terraform-locks`

## Cleanup

To destroy resources in correct order:

```bash
# 1. Destroy VPC resources
cd 4_VPC_Remote_State
terraform destroy

# 2. Destroy S3 bucket and DynamoDB (must empty S3 first)
cd ../backend-setup

# Empty S3 bucket versions
aws s3 rm s3://my-terraform-state-bucket-ACCOUNT_ID --recursive --include "*"

# Then destroy
terraform destroy
```

## Important Notes

⚠️ **S3 Bucket Name**: Must be globally unique across AWS, so it includes account ID
⚠️ **Backend Config**: Cannot use variables, must use hardcoded values or `-backend-config` on init
⚠️ **State File**: Never delete the S3 state file manually
⚠️ **DynamoDB Locking**: Prevents concurrent operations (terraform apply by multiple users)
⚠️ **First Run**: Run backend_setup.tf in separate directory FIRST

## Advanced: Backend Config on Init

Instead of hardcoding S3 bucket name in provider.tf, you can pass it during init:

**provider.tf (without backend block):**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

**Initialize with backend config:**
```bash
terraform init \
  -backend-config="bucket=my-terraform-state-bucket-ACCOUNT_ID" \
  -backend-config="key=vpc/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-locks"
```

This approach is useful for CI/CD pipelines where bucket name varies.
