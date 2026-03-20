# Simple VPC with S3 Bucket as Resource (Backend)

Minimal Terraform setup that creates both an S3 bucket and VPC as resources, with complete backend infrastructure as code - no separate setup scripts needed.

## 📁 Directory Structure

```
8_Simple_VPC_S3_Bare_Minimum/
├── backend.tf           # Local backend (all resources created in main.tf)
├── provider.tf          # AWS provider
├── variables.tf         # Variable definitions
├── main.tf              # All S3 backend + VPC resources
├── outputs.tf           # Resource outputs
├── terraform.tfvars     # Variable values
├── setup-backend.sh     # Info only (not needed - for reference)
└── README.md
```

## 🚀 Quick Start (2 Steps Only)

### Step 1: Initialize Terraform

```bash
terraform init
```

### Step 2: Deploy Everything (S3 Backend + VPC)

```bash
terraform plan
terraform apply
```

**That's it!** No setup script needed. Everything is code.

## 🔧 How It Works - Backend as Code

All backend infrastructure is defined as resources in `main.tf`:

1. **S3 Bucket Resource**: `aws_s3_bucket`
2. **Versioning Resource**: `aws_s3_bucket_versioning`
3. **Encryption Resource**: `aws_s3_bucket_server_side_encryption_configuration`
4. **Public Access Block Resource**: `aws_s3_bucket_public_access_block`
5. **VPC Resource**: `aws_vpc`

No imperative scripts - pure declarative infrastructure as code!

## 🔧 Files Explained

### backend.tf
**Phase 1: Local backend (resources created first)**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }

  backend "local" {
    path = "terraform.tfstate"
  }

  # Optional: Migrate to S3 backend after first apply
  # Uncomment s3 backend block and run:
  #   terraform init -migrate-state
}
```

**Phase 2: Migrate to S3 (after first apply)**
1. Uncomment the `backend "s3"` block in backend.tf
2. Run `terraform init -migrate-state`
3. State automatically migrates to S3

### main.tf
**Complete backend infrastructure as code:**
```hcl
# S3 Bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
  tags = { Name = "Terraform State Bucket" }
}

# Versioning (for recovery + locking)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration { status = "Enabled" }
}

# Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = var.vpc_name }
}
```

### provider.tf
```hcl
provider "aws" {
  region = var.aws_region
}
```

### main.tf
**S3 Bucket as Resource:**
```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**VPC Resource:**
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

## 🔑 Key Commands

```bash
# No setup script needed - everything is Terraform!

# 1. Initialize (uses local backend)
terraform init

# 2. Plan changes
terraform plan

# 3. Apply (creates all resources: S3 bucket + VPC)
terraform apply

# 4. View outputs
terraform output

# 5. View state (stored locally)
terraform state list
terraform state show aws_vpc.main
terraform state show aws_s3_bucket.terraform_state

# 6. View S3 versions (for recovery or state history)
aws s3api list-object-versions \
  --bucket my-terraform-state-bare-minimum

# 7. (Optional) Migrate to S3 backend
#    a. Uncomment S3 backend block in backend.tf
#    b. terraform init -migrate-state

# 8. Destroy resources
terraform destroy
```

## 🔒 Backend Infrastructure as Code

**Complete backend setup via resources (no scripts):**

✅ **S3 Bucket** - Created by resource, globally unique name
✅ **Versioning** - Enabled for recovery and locking support
✅ **Encryption** - AES256 encryption at rest
✅ **Public Access Block** - All public access blocked
✅ **Declarative** - Pure infrastructure as code
✅ **Reproducible** - Same config = same infrastructure

**Migration Path:**
```
Phase 1: Local Backend
├─ State: terraform.tfstate (local file)
├─ Resources: S3 bucket, VPC created
└─ Cost: Minimal

Phase 2: S3 Backend (optional)
├─ Uncomment S3 backend block
├─ Run: terraform init -migrate-state
├─ State: S3 remote storage
└─ Cost: Same (~$1-2/month)
```

## 📊 Resources Created

✅ **S3 Bucket**
- Versioning enabled (recovery capability)
- Encryption enabled (AES256)
- Public access blocked
- Managed by Terraform

✅ **VPC** (10.0.0.0/16)
- DNS enabled
- DNS hostnames enabled

## ⚠️ Important Notes

1. **No Setup Script**: Everything defined in `main.tf` resources
2. **Local Backend Initially**: State stored in `terraform.tfstate` (local file)
3. **S3 Bucket Created by Terraform**: Managed like any other resource
4. **Bucket Name**: Must be globally unique (change in `terraform.tfvars` if needed)
5. **Versioning**: S3 versioning enabled for recovery capability
6. **Encryption**: All S3 content encrypted at rest (AES256)
7. **Two Regions of Code**: Resources in main.tf, configuration in backend.tf
8. **Optional S3 Migration**: Can migrate to S3 backend after first apply

## ⚡ Advantages

✅ **No Scripts** - Pure infrastructure as code
✅ **Simple Workflow** - Just `terraform init` and `terraform apply`
✅ **Managed as Code** - S3 bucket is a Terraform resource
✅ **Versioning Protection** - S3 versioning for recovery
✅ **Encrypted** - State protected (AES256)
✅ **Reproducible** - Same code = same infrastructure
✅ **Cost Effective** - Minimal S3 costs (~$1/month)
✅ **Flexible** - Can migrate to S3 backend anytime

## 📝 Outputs After Apply

```
s3_bucket_id = "my-terraform-state-bare-minimum"
s3_bucket_arn = "arn:aws:s3:::my-terraform-state-bare-minimum"
vpc_id = "vpc-0123456789abcdef"
vpc_cidr = "10.0.0.0/16"
```

## 🔄 Comparison: Different Approaches

| Feature | Version 5 (Remote S3) | **Version 8 (Resources)** | Version 6 (Object Lock) | Version 7 (DynamoDB) |
|---------|-------|---------------------------|----------------------|------------|
| Remote State | ✅ S3 | ❌ Local (opt. S3) | ✅ S3 | ✅ S3 |
| Setup Script | Yes | **No** | Yes | Yes |
| S3 Bucket | Resource | **Resource** | Resource | Resource |
| Backend Config | S3 | **Local** | S3 | S3 |
| Infrastructure | Infrastructure | **Infrastructure** | Infrastructure | Infrastructure |
| Simplicity | Medium | **High** | Medium | Medium |
| Cost | $1-2/month | **$1-2/month** | $1-2/month | $2-3/month |
| Concurrent Applies | ❌ Not prevented | ❌ **Not prevented** | ❌ Not prevented | ✅ Yes |
| Pure IaC | ⚠️ Partial | ✅ **Yes** | ⚠️ Partial | ⚠️ Partial |

## ✅ When to Use This Setup

**Perfect for:**
- ✅ Learning infrastructure as code best practices
- ✅ Teams preferring no setup scripts
- ✅ Projects that are fully declarative
- ✅ Easy reproducibility and version control
- ✅ Single developer with versioning recovery
- ✅ S3 bucket management as part of infrastructure

**Consider alternatives if:**
- 🚨 Need remote state immediately → Uncomment S3 backend
- 🚨 Multiple users, different machines → Use Version 7 (DynamoDB)
- 🚨 Need immutability enforcement → Use Version 6 (Object Lock)

## 🗑️ Cleanup

```bash
# Step 1: Destroy all Terraform resources (S3 bucket + VPC)
terraform destroy

# Step 2: Clean local files (optional)
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*
```

All resources (including S3 bucket) are destroyed with `terraform destroy`!

## 📝 Complete Workflow

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `terraform init` | Initialize (uses local backend) |
| 2 | `terraform plan` | Preview infrastructure changes |
| 3 | `terraform apply` | Create S3 bucket resource + VPC |
| 4 | `terraform output` | View resource outputs |
| 5 | `terraform state list` | List managed resources |
| 6 | `terraform state show <resource>` | View resource details |
| 7 | `terraform destroy` | Destroy all resources |

**No setup scripts required - everything is code!**
