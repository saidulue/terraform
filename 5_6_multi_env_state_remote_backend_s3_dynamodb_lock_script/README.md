# Multi-Environment VPC with Remote State (S3 + DynamoDB)

Complete setup for deploying VPCs across dev, test, and prod environments with centralized remote state management.

## 📁 Directory Structure

```
5_Multi_Env_Remote_State/
├── provider.tf              # AWS provider + S3 backend
├── variables.tf             # VPC variables (shared)
├── main.tf                  # VPC resources (shared)
├── outputs.tf               # Output values (shared)
├── setup-backend.sh         # Backend setup script
├── deploy.sh                # Bash deployment script
├── deploy.ps1               # PowerShell deployment script
├── dev/
│   └── terraform.tfvars     # Dev environment values
├── test/
│   └── terraform.tfvars     # Test environment values
└── prod/
    └── terraform.tfvars     # Prod environment values
```

## 🚀 Quick Start (4 Steps)

### Step 1: Create Remote Backend Infrastructure

```bash
# Setup S3 bucket and DynamoDB table
bash setup-backend.sh

# Output will show:
# - Bucket name: my-terraform-state-bucket-ACCOUNT_ID
# - DynamoDB table: terraform-locks
```

### Step 2: Update provider.tf with S3 Bucket Name

In **provider.tf**, update the bucket name:
```hcl
backend "s3" {
  bucket         = "my-terraform-state-bucket-123456789"  # Replace with actual
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

### Step 3: Initialize Environment

Choose ONE method below:

**Option A - Using Bash Script (Recommended for Linux/Mac):**
```bash
bash deploy.sh dev init
bash deploy.sh test init
bash deploy.sh prod init
```

**Option B - Using PowerShell:**
```powershell
.\deploy.ps1 -Environment dev -Action init
.\deploy.ps1 -Environment test -Action init
.\deploy.ps1 -Environment prod -Action init
```

**Option C - Manual (with environment variables):**
```bash
export ENVIRONMENT=dev
export BUCKET_NAME=my-terraform-state-bucket-123456789

terraform init \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="key=$ENVIRONMENT/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-locks"
```

### Step 4: Deploy Resources

```bash
# Deploy dev
bash deploy.sh dev plan
bash deploy.sh dev apply

# Deploy test
bash deploy.sh test plan
bash deploy.sh test apply

# Deploy prod
bash deploy.sh prod plan
bash deploy.sh prod apply
```

## 📋 Deployment Options

### Option 1: Bash Deployment Script (Recommended for CI/CD)

Most consistent and scriptable approach.

```bash
# Initialize all environments
for env in dev test prod; do
  bash deploy.sh $env init
done

# Plan all environments
for env in dev test prod; do
  bash deploy.sh $env plan
done

# Apply to specific environment
bash deploy.sh dev apply
bash deploy.sh test apply
bash deploy.sh prod apply

# Destroy in reverse order (prod first)
bash deploy.sh prod destroy
bash deploy.sh test destroy
bash deploy.sh dev destroy
```

### Option 2: PowerShell Deployment Script

For Windows environments.

```powershell
# Initialize all environments
'dev', 'test', 'prod' | ForEach-Object {
  .\deploy.ps1 -Environment $_ -Action init
}

# Deploy dev
.\deploy.ps1 -Environment dev -Action plan
.\deploy.ps1 -Environment dev -Action apply

# Deploy test
.\deploy.ps1 -Environment test -Action plan
.\deploy.ps1 -Environment test -Action apply

# Deploy prod
.\deploy.ps1 -Environment prod -Action plan
.\deploy.ps1 -Environment prod -Action apply
```

### Option 3: Manual Commands (Full Control)

For when you need more flexibility.

```bash
# Get AWS account ID (needed for bucket name)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="my-terraform-state-bucket-${ACCOUNT_ID}"

# Initialize with dev backend config
terraform init \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-locks"

# Plan changes
terraform plan -var-file="./dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="./dev/terraform.tfvars"

# Switch to test environment
terraform init -reconfigure \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="key=test/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-locks"

terraform apply -var-file="./test/terraform.tfvars"

# Repeat for prod...
```

### Option 4: Terraform Workspaces (Advanced)

Separate workspaces with same backend.

```bash
# Create workspaces
terraform workspace new dev
terraform workspace new test
terraform workspace new prod

# Switch to dev
terraform workspace select dev
terraform init \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="key=workspaces/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-locks"
terraform apply -var-file="./dev/terraform.tfvars"

# Switch to test
terraform workspace select test
terraform apply -var-file="./test/terraform.tfvars"

# Switch to prod
terraform workspace select prod
terraform apply -var-file="./prod/terraform.tfvars"

# List workspaces
terraform workspace list
```

### Option 5: CI/CD Pipeline (GitHub Actions)

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, test, prod]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Terraform Init
        run: bash deploy.sh ${{ matrix.environment }} init
      
      - name: Terraform Plan
        run: bash deploy.sh ${{ matrix.environment }} plan
      
      - name: Terraform Apply
        if: github.event_name == 'push'
        run: bash deploy.sh ${{ matrix.environment }} apply
```

## 🔧 Environment Configuration

### dev/terraform.tfvars
- **VPC CIDR**: 10.0.0.0/16
- **Instance Type**: t2.micro (cost-optimized)
- **NAT Gateway**: Disabled (save costs)
- **Flow Logs**: Enabled (7 days retention)

### test/terraform.tfvars
- **VPC CIDR**: 10.1.0.0/16
- **Instance Type**: t2.small
- **NAT Gateway**: Disabled
- **Flow Logs**: Enabled

### prod/terraform.tfvars
- **VPC CIDR**: 10.2.0.0/16
- **Instance Type**: t2.medium (better performance)
- **NAT Gateway**: Enabled (always available)
- **Flow Logs**: Enabled

## 📊 Resources Created per Environment

Each environment deploys:
- ✅ VPC (with DNS enabled)
- ✅ Public Subnet
- ✅ Internet Gateway
- ✅ Route Table + Routes
- ✅ Network ACL
- ✅ NAT Gateway (prod only)
- ✅ VPC Flow Logs (CloudWatch)
- ✅ IAM Roles for Flow Logs

## 🌐 Remote State Architecture

```
┌─────────────────────────────────────────┐
│   AWS Account                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ S3 Bucket (Terraform State)     │   │
│  ├─────────────────────────────────┤   │
│  │ /dev/terraform.tfstate          │   │
│  │ /test/terraform.tfstate         │   │
│  │ /prod/terraform.tfstate         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ DynamoDB Table (State Locks)    │   │
│  │ - Prevents concurrent applies   │   │
│  │ - Auto-cleanup on release       │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

## 🔒 Security Features

✅ **Encryption**: S3 state files encrypted at rest (AES256)
✅ **Versioning**: S3 versioning enabled for rollback
✅ **Access Control**: Public access blocked
✅ **Locking**: DynamoDB prevents concurrent operations
✅ **Audit**: VPC Flow Logs enable security monitoring
✅ **Isolation**: Separate environments in separate S3 paths

## 📝 Common Commands

```bash
# List all state resources
terraform state list -var-file="./dev/terraform.tfvars"

# Show specific resource
terraform state show -var-file="./dev/terraform.tfvars" aws_vpc.main

# Get all outputs
terraform output -var-file="./dev/terraform.tfvars"

# Get specific output
terraform output -var-file="./dev/terraform.tfvars" vpc_id

# Check remote state
aws s3 ls s3://my-terraform-state-bucket-ACCOUNT_ID/

# View state lock info
aws dynamodb scan --table-name terraform-locks
```

## 🗑️ Cleanup (Destroy Resources)

Always destroy in reverse order (prod → test → dev):

```bash
# Destroy prod
bash deploy.sh prod destroy

# Destroy test
bash deploy.sh test destroy

# Destroy dev
bash deploy.sh dev destroy

# Optional: Clean S3 bucket (if you want to remove all state)
aws s3 rm s3://my-terraform-state-bucket-ACCOUNT_ID --recursive

# Optional: Delete S3 bucket (must be empty first)
aws s3 rb s3://my-terraform-state-bucket-ACCOUNT_ID

# Optional: Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-locks
```

## ⚠️ Important Notes

1. **Bucket Name**: Includes AWS account ID to ensure global uniqueness
2. **Backend Config**: Cannot use variables - must be hardcoded or passed via `-backend-config`
3. **State Files**: Never manually delete S3 state files
4. **Locking**: DynamoDB automatically releases locks after 5 minutes
5. **Costs**: S3 and DynamoDB have minimal costs (~$1-2/month)
6. **Access**: IAM user needs S3 and DynamoDB permissions

## 🐛 Troubleshooting

**Error: "Backend state lock conflict"**
```bash
# View locks
aws dynamodb scan --table-name terraform-locks

# Force unlock (use with caution)
terraform force-unlock LOCK_ID -var-file="./dev/terraform.tfvars"
```

**Error: "S3 bucket does not exist"**
```bash
# Run backend setup again
bash setup-backend.sh
```

**Error: "State file corrupted"**
```bash
# Terraform maintains version history
aws s3api list-object-versions --bucket my-terraform-state-bucket-ACCOUNT_ID --prefix dev/
```

## 📚 Further Reading

- [Terraform Remote Backends](https://www.terraform.io/docs/backends)
- [S3 Backend State Locking](https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table)
- [Terraform Multi-Environment Guide](https://www.terraform.io/docs/language/state/workspaces.html)
