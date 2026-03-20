# Simple VPC with S3 Remote State + Object Lock

Minimal Terraform setup to create a VPC with remote state in S3 and state file protection via S3 Object Lock.

## 📁 Directory Structure

```
6_Simple_VPC_Remote_State_With_Lock/
├── backend.tf           # S3 backend with Object Lock config
├── provider.tf          # AWS provider
├── variables.tf         # VPC variables
├── main.tf              # VPC resource only
├── outputs.tf           # VPC outputs
├── terraform.tfvars     # Variable values
├── setup-backend.sh     # Create S3 bucket with Object Lock
└── README.md
```

## 🚀 Quick Start (3 Steps)

### Step 1: Create S3 Bucket with Object Lock

```bash
bash setup-backend.sh

# Output:
# ✓ S3 bucket created with Object Lock
# ✓ Versioning enabled
# ✓ Encryption enabled
# ✓ Public access blocked
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Deploy VPC

```bash
# Plan changes
terraform plan

# Apply changes (locks state automatically during apply)
terraform apply

# View outputs
terraform output
```

## 🔧 Files Explained

### backend.tf
**Separate backend configuration with S3 Object Lock:**
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
    bucket  = "my-terraform-state-s3-locked"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # S3 Object Lock protects state files from deletion/modification
  }
}
```

**Note:** Object Lock is configured on the bucket separately (via `setup-backend.sh`) and provides immutability protection.

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
# Setup backend infrastructure with Object Lock
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

# Check Object Lock configuration
aws s3api get-object-lock-configuration --bucket my-terraform-state-s3-locked
```

## 🔒 How State Protection Works

S3 Object Lock provides **immutability** protection for state files:

1. **Write Once Read Many (WORM)**: State files are protected from deletion/modification
2. **Versioning Enabled**: All changes are tracked with version IDs
3. **Encryption At Rest**: State data is encrypted with AES256
4. **Protection Modes**:
   - **GOVERNANCE Mode**: Privileged users can override protection
   - **COMPLIANCE Mode**: No overrides possible (stricter)

**Key Difference from DynamoDB Locking:**
- ✅ S3 Object Lock: Prevents accidental state corruption (data protection)
- ❌ S3 Object Lock: Does NOT prevent concurrent terraform applies
- 💡 For truly safe concurrent team environments, combine with `-lock` flag in CI/CD

**Note:** Unlike DynamoDB locking which prevents concurrent `terraform apply`, S3 Object Lock only prevents accidental state file deletion/corruption after the fact.

## 📊 Resources Created

✅ **VPC** (10.0.0.0/16)
- DNS enabled
- DNS hostnames enabled
- Named and tagged

## 🛡️ State Protection Benefits

✅ **Prevents Accidental Deletion** - State files cannot be deleted during Object Lock retention
✅ **Data Immutability** - Ensures state file integrity and prevents corruption
✅ **Compliance Protection** - COMPLIANCE mode meets strict audit requirements
✅ **Automatic Recovery** - Versioning restores previous state if needed
✅ **Secure Storage** - Encrypted at rest with AES256
✅ **Cost Efficient** - No additional service costs (included in S3)

## 📊 Remote State Info

**S3 Bucket:** `my-terraform-state-s3-locked`
**State Path:** `s3://my-terraform-state-s3-locked/vpc/terraform.tfstate`
**Protection:** S3 Object Lock (GOVERNANCE mode)

**Features:**
- ✅ Encrypted at rest (AES256)
- ✅ Versioning enabled (rollback capability)
- ✅ Public access blocked (secure)
- ✅ **S3 Object Lock** (immutability protection)
- ✅ Remote storage (shared across team)

## ⚠️ Important Notes

1. **Object Lock Protection**: Prevents accidental state file deletion/modification after writes
2. **Bucket Name**: Must be globally unique
3. **Encryption**: All state files encrypted at rest
4. **Versioning**: Keeps history for rollback
5. **GOVERNANCE Mode**: Allows privileged users to override retention for emergency recovery
6. **Concurrent Safety**: For preventing concurrent applies in teams, use CI/CD locking or `-lock` flag
7. **Retention Period**: Currently set to 365 days (configurable)

## 💰 Cost

Very minimal cost:
- S3 bucket: ~$0.023/GB
- S3 versioning: ~0.023/GB per version
- Object Lock: No additional cost
- **Total:** ~$1-2/month (lower than DynamoDB approach)

## 🗑️ Cleanup

```bash
# Destroy VPC resources
terraform destroy

# Delete S3 bucket (empty it first - may need to disable Object Lock)
aws s3 rm s3://my-terraform-state-s3-locked --recursive
aws s3 rb s3://my-terraform-state-s3-locked

# To force delete with Object Lock in GOVERNANCE mode:
aws s3 rm s3://my-terraform-state-s3-locked --recursive --bypass-governance-retention
aws s3 rb s3://my-terraform-state-s3-locked
```

## 🔄 Comparison: Protection Strategies

| Feature | Without Protection | **S3 Object Lock (This)** | DynamoDB Lock |
|---------|-----------------|--------------------------|----------------|
| Remote State | ✅ S3 | ✅ S3 | ✅ S3 |
| Encryption | ✅ Yes | ✅ Yes | ✅ Yes |
| Versioning | ✅ Yes | ✅ Yes | ✅ Yes |
| **Data Protection** | ❌ None | ✅ **Immutability** | ❌ None |
| **Concurrent Apply Prevention** | ❌ No | ❌ No | ✅ **Yes** |
| Accidental Deletion | ❌ Risky | ✅ **Protected** | ❌ Risky |
| Team Safe | ⚠️ Manual | ✅ **For accidents** | ✅ **For applies** |
| Cost | $1-2/month | $1-2/month | $2-3/month |
| Use Case | Single dev | Team + Protection | Team + Concurrency |

## ✅ When to Use This Setup

**Perfect for:**
- ✅ Teams that want state file immutability protection
- ✅ Preventing accidental state file deletion
- ✅ Compliance requirements (audit trail)
- ✅ Disaster recovery (version history)
- ✅ Cost-conscious teams (no DynamoDB cost)
- ✅ Single-region deployments

**Consider DynamoDB Locking (5_Multi_Env_Remote_State) instead if:**
- 🚨 Multiple users run `terraform apply` simultaneously
- 🚨 You need active concurrent apply prevention
- 🚨 Multi-region concurrent deployments
- 🚨 Strict operational safety (not just data protection)

**Use WITHOUT any locking (5_State_Remote_S3_WO_Locking) only for:**
- ❌ Single developer projects
- ❌ Personal labs
- ❌ Learning purposes

## 📚 File Structure Best Practices

**Separate backend.tf** provides:
- ✅ Clear organization
- ✅ Easy to find backend config
- ✅ Standard Terraform convention
- ✅ Better for teams
- ✅ CI/CD friendly

## 🔧 Troubleshooting

**Error: "Access Denied" when deleting state file**
```bash
# Object Lock is preventing deletion - bypass GOVERNANCE mode
aws s3 rm s3://my-terraform-state-s3-locked/vpc/terraform.tfstate \
  --bypass-governance-retention
```

**Error: "Cannot create bucket with Object Lock"**
```bash
# Object Lock must be enabled at bucket creation time
# Delete and recreate bucket with Object Lock
bash setup-backend.sh
```

**Error: "State version has legal hold"**
```bash
# Release legal hold if set
aws s3api put-object-legal-hold \
  --bucket my-terraform-state-s3-locked \
  --key vpc/terraform.tfstate \
  --legal-hold Status=OFF
```

**Error: Cannot reinitialize because state is read-only**
```bash
# Check retention settings
aws s3api get-object-retention \
  --bucket my-terraform-state-s3-locked \
  --key vpc/terraform.tfstate

# For emergency bypass (GOVERNANCE only):
terraform init -reconfigure -upgrade
```
```

**Error: "S3 bucket access denied"**
```bash
# Check IAM permissions
aws iam get-user
# Ensure user has S3 and DynamoDB permissions
```

## 📖 Summary

This setup provides:
- 📦 **Simple VPC** creation
- 🌍 **Remote state** in S3
- 🔒 **State locking** via DynamoDB
- 🔐 **Encryption** at rest
- 👥 **Team-safe** operations
- 📊 **Versioning** for rollback
- ✅ **Separated config** (clean organization)

Perfect for production-grade Terraform deployments! 🚀
