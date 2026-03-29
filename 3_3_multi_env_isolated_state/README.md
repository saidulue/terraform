# Multi-Environment Terraform Setup with Isolated State Management

This is an **optimized multi-environment setup** with **explicit state isolation** for each environment. Each environment maintains its own separate state file, preventing any interference between development, test, and production deployments.

## 🎯 Key Features

✅ **Complete State Isolation** - Each environment has independent `terraform.tfstate`
✅ **No Code Duplication** - Shared `.tf` files with environment-specific variables only
✅ **Multi-User Safe** - Different users can manage different environments simultaneously
✅ **Automatic State Switching** - Deploy scripts handle state file path configuration
✅ **Cross-Platform Scripts** - Bash and PowerShell deployment scripts included
✅ **Dependency Management** - Explicit resource ordering prevents VPC deletion errors

## 📁 Directory Structure

```
3_3_multi_env_isolated_state/
├── backend.tf               # Local backend with environment-specific path config
├── provider.tf              # AWS provider configuration
├── variables.tf             # Input variables with validation
├── main.tf                  # Shared AWS resources (VPC, Subnet, IGW, EC2, etc.)
├── outputs.tf               # Resource outputs
├── deploy.sh                # Bash deployment script (RECOMMENDED)
├── deploy.ps1               # PowerShell deployment script
├── .gitignore               # Ignore state files and terraform cache
├── dev/
│   ├── terraform.tfvars     # Dev environment variables
│   └── terraform.tfstate    # Dev state file (auto-created on first apply)
├── test/
│   ├── terraform.tfvars     # Test environment variables
│   └── terraform.tfstate    # Test state file (auto-created on first apply)
└── prod/
    ├── terraform.tfvars     # Production environment variables
    └── terraform.tfstate    # Prod state file (auto-created on first apply)
```

## 🔑 How State Isolation Works

The `deploy.sh` script automatically configures the backend path per environment:

```bash
# For dev environment:
terraform init -backend-config="path=dev/terraform.tfstate" -reconfigure

# For test environment:
terraform init -backend-config="path=test/terraform.tfstate" -reconfigure

# For prod environment:
terraform init -backend-config="path=prod/terraform.tfstate" -reconfigure
```

This ensures:
- **User1** managing dev works with `dev/terraform.tfstate` only
- **User2** managing test works with `test/terraform.tfstate` only
- **User3** managing prod works with `prod/terraform.tfstate` only
- **No state conflicts** - Each user operates independently

## 🚀 Deployment Methods

### Method 1: Using Deployment Scripts (RECOMMENDED)

**Linux/Mac (Bash):**
```bash
# Navigate to folder
cd 3_3_multi_env_isolated_state

# Dev Environment
./deploy.sh dev plan
./deploy.sh dev apply
./deploy.sh dev destroy

# Test Environment
./deploy.sh test plan
./deploy.sh test apply
./deploy.sh test destroy

# Production Environment
./deploy.sh prod plan
./deploy.sh prod apply
./deploy.sh prod destroy
```

**Windows (PowerShell):**
```powershell
# Navigate to folder
cd 3_3_multi_env_isolated_state

# Dev Environment
.\deploy.ps1 dev plan
.\deploy.ps1 dev apply
.\deploy.ps1 dev destroy

# Test Environment
.\deploy.ps1 test plan
.\deploy.ps1 test apply
.\deploy.ps1 test destroy

# Production Environment
.\deploy.ps1 prod plan
.\deploy.ps1 prod apply
.\deploy.ps1 prod destroy
```

### Method 2: Manual Commands

```bash
# Development
terraform init -backend-config="path=dev/terraform.tfstate" -reconfigure -upgrade
terraform plan -var-file="./dev/terraform.tfvars"
terraform apply -var-file="./dev/terraform.tfvars"

# Test
terraform init -backend-config="path=test/terraform.tfstate" -reconfigure -upgrade
terraform plan -var-file="./test/terraform.tfvars"
terraform apply -var-file="./test/terraform.tfvars"

# Production
terraform init -backend-config="path=prod/terraform.tfstate" -reconfigure -upgrade
terraform plan -var-file="./prod/terraform.tfvars"
terraform apply -var-file="./prod/terraform.tfvars"
```

## 📋 Configuration Files

### backend.tf
Configures local backend with dynamic path based on `-backend-config` parameter provided during `terraform init`

### provider.tf
AWS provider configuration sourcing region from variables

### variables.tf
Input variables with validation:
- `aws_region` - AWS region (default: us-east-1)
- `environment` - Environment name (validation: dev|test|prod)
- `vpc_cidr` - VPC CIDR block
- `vpc_name` - VPC name tag
- `subnet_cidr` - Public subnet CIDR
- `availability_zone` - AWS availability zone
- `instance_type` - EC2 instance type
- `ami_id` - AMI ID for the instance
- `instance_name` - Instance name tag

### main.tf
AWS resources with explicit dependency management:
- VPC with DNS enabled
- Public Subnet
- Internet Gateway with explicit attachment (prevents deletion errors)
- Route Table and Route Table Association
- Security Group (SSH, HTTP, HTTPS)
- EC2 Instance with public IP

**Key Dependencies:**
```
Subnet → VPC
IGW Attachment → IGW + VPC
Route Table → IGW Attachment
Route Table Association → Route Table + Subnet
Security Group → VPC
EC2 Instance → Subnet + Security Group + IGW Attachment
```

### outputs.tf
Outputs include: VPC ID, Subnet ID, IGW ID, Security Group ID, Instance ID, Instance Public/Private IPs, Environment name

### Environment-Specific terraform.tfvars
- `dev/terraform.tfvars` - Development configuration
- `test/terraform.tfvars` - Test configuration
- `prod/terraform.tfvars` - Production configuration

## 💻 Common Terraform Commands

```bash
# Format and validate
terraform fmt
terraform validate

# Show all resources in current state
terraform state list

# Show specific resource details
terraform state show aws_instance.webserver

# Get output values
terraform output

# Get specific output
terraform output instance_public_ip

# View state file directly (useful for debugging)
cat dev/terraform.tfstate
cat test/terraform.tfstate
cat prod/terraform.tfstate
```

## 📖 Typical Workflow

```bash
# 1. Configure environments (dev, test, prod terraform.tfvars already provided)
#    Customize values as needed

# 2. Deploy to Dev (User1)
./deploy.sh dev plan      # Review changes
./deploy.sh dev apply     # Create dev resources

# 3. Deploy to Test (User2) - Completely independent
./deploy.sh test plan     # Should show 8 to create (not destroy!)
./deploy.sh test apply    # Create test resources

# 4. Deploy to Prod (User3) - Also completely independent
./deploy.sh prod plan
./deploy.sh prod apply

# 5. Verify each environment is separate
./deploy.sh dev plan      # Should show "No changes"
./deploy.sh test plan     # Should show "No changes"
./deploy.sh prod plan     # Should show "No changes"

# 6. View outputs per environment
terraform init -backend-config="path=dev/terraform.tfstate" -reconfigure
terraform output

terraform init -backend-config="path=test/terraform.tfstate" -reconfigure
terraform output

terraform init -backend-config="path=prod/terraform.tfstate" -reconfigure
terraform output
```

## ⚠️ Important Notes

1. **State File Isolation**: Each environment's state file is separate and independent
2. **Backend Reconfiguration**: The deployment scripts use `-reconfigure` flag to switch backends
3. **First Apply**: Each environment's `terraform.tfstate` is created on first `terraform apply`
4. **.gitignore**: State files are excluded from git to prevent conflicts
5. **Resource Dependencies**: Explicit `depends_on` declarations ensure proper creation/destruction order
6. **Internet Gateway Attachment**: Separated as explicit resource to prevent VPC deletion errors

## 🔍 Troubleshooting

**Problem: "State file not found" when running deploy.sh**
```bash
# Solution: Just run deploy.sh - it will create the state file on first apply
./deploy.sh dev apply
```

**Problem: "Error: deleting EC2 VPC...has dependencies"**
```bash
# Solution: Explicit depends_on declarations in main.tf handle this
# Don't try to manually delete - use deploy.sh destroy
./deploy.sh dev destroy
```

**Problem: Multiple users want to deploy simultaneously**
```bash
# Solution: This setup is built for this!
# User1: ./deploy.sh dev apply
# User2: ./deploy.sh test apply  (simultaneously - completely separate state)
# User3: ./deploy.sh prod apply
```

## 📊 State File Structure After Deployment

```
3_3_multi_env_isolated_state/
├── .terraform/              # Terraform working directory
├── dev/
│   ├── terraform.tfstate    # Dev resources (created after first apply)
│   └── terraform.tfvars
├── test/
│   ├── terraform.tfstate    # Test resources (created after first apply)
│   └── terraform.tfvars
└── prod/
    ├── terraform.tfstate    # Prod resources (created after first apply)
    └── terraform.tfvars
```

Each `.tfstate` file contains ONLY that environment's resources, making multi-environment management safe and scalable.
