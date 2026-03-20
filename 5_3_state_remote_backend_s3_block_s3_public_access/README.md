# Simple VPC with S3 Remote State + Simple Lock

Minimal Terraform setup to create a VPC with remote state in S3 and simple state file protection using versioning and bucket policies.

## 📁 Directory Structure

```
7_Simple_VPC_S3_Simple_State_Lock/
├── backend.tf           # S3 backend config
├── provider.tf          # AWS provider
├── variables.tf         # VPC variables
├── main.tf              # VPC resource only
├── outputs.tf           # VPC outputs
├── terraform.tfvars     # Variable values
├── setup-backend.sh     # Create S3 with simple protection
└── README.md
```

## 🚀 Quick Start (3 Steps)

### Step 1: Create S3 Bucket with Simple Protection

```bash
bash setup-backend.sh

# Output:
# ✓ S3 bucket created
# ✓ Versioning enabled
# ✓ Encryption enabled
# ✓ Public access blocked
# ✓ Bucket policy applied
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

## 🔧 Files Explained

### backend.tf
**Simple S3 backend configuration:**
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
    bucket  = "my-terraform-state-simple-lock"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # Simple S3 state protection:
    # - Versioning enabled (recovery capability)
    # - Encryption enabled (data at rest)
    # - Bucket policy prevents unauthorized deletion
    # - Public access blocked
  }
}
```

### provider.tf
**Clean provider configuration:**
```hcl
provider "aws" {
  region = var.aws_region
}
```

### main.tf
**Simple VPC resource:**
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
# Setup backend infrastructure
bash setup-backend.sh

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# View state
terraform state list
terraform state show aws_vpc.main

# Destroy resources
terraform destroy

# View versioning
aws s3api list-object-versions --bucket my-terraform-state-simple-lock
```

## 🔒 How Simple State Protection Works

**Versioning + Encryption + Bucket Policy provide:**

1. **Versioning**: Keeps history of all state file changes for recovery
2. **Encryption**: Protects state data at rest with AES256
3. **Public Access Block**: Prevents accidental public exposure
4. **Bucket Policy**: Enforces TLS-only access and prevents unauthorized deletion
5. **Protection from accidents**: Can recover deleted files from version history

**What this does NOT provide:**
- ❌ Prevention of concurrent terraform applies (use DynamoDB or CI/CD locking for that)
- ❌ Immutability enforcement (use S3 Object Lock for that)
- ❌ Active operational locking during Terraform operations

**What this DOES provide:**
- ✅ Data protection (encryption)
- ✅ Recovery capability (versioning)
- ✅ Basic access control (bucket policy)
- ✅ Secure transport (TLS enforcement)
- ✅ Simple, low-cost protection