# Multi-Environment Terraform Setup (DRY - Don't Repeat Yourself)

This optimized structure keeps **shared Terraform configurations** in the root directory and **environment-specific variables** in separate folders. This eliminates code duplication while maintaining separate state files for each environment.

## Optimized Directory Structure

```
3_Custom_config_terraform-tfvars_each_env/
├── provider.tf              # Shared for all environments
├── variables.tf             # Shared for all environments
├── main.tf                  # Shared for all environments
├── outputs.tf               # Shared for all environments
├── deploy.sh                # Bash deployment script
├── deploy.ps1               # PowerShell deployment script
├── dev/
│   ├── terraform.tfvars     # Dev-specific values only
│   └── terraform.tfstate    # Dev state file (auto-created)
├── test/
│   ├── terraform.tfvars     # Test-specific values only
│   └── terraform.tfstate    # Test state file (auto-created)
└── prod/
    ├── terraform.tfvars     # Prod-specific values only
    └── terraform.tfstate    # Prod state file (auto-created)
```

## Advantages

✅ **No Code Duplication** - `.tf` files exist only in root
✅ **Separate State Files** - Each environment has isolated state
✅ **Easy Maintenance** - Update logic once, applies to all environments
✅ **Individual Deployment** - Deploy any environment independently
✅ **Clean Organization** - Variables only change per environment

## Environment-Specific terraform.tfvars

### dev/terraform.tfvars
### test/terraform.tfvars
### prod/terraform.tfvars

## Deployment Methods

### Method 1: Using Deployment Scripts (Recommended)

**Bash:**
```bash
# Plan changes
./deploy.sh dev plan
./deploy.sh test plan
./deploy.sh prod plan

# Deploy changes
./deploy.sh dev apply
./deploy.sh test apply
./deploy.sh prod apply

# Destroy resources
./deploy.sh dev destroy
./deploy.sh test destroy
./deploy.sh prod destroy
```

### Method 2: Manual Commands from Root Directory

**Development:**
```bash
terraform init
terraform plan -var-file="./dev/terraform.tfvars"
terraform apply -var-file="./dev/terraform.tfvars"
```

**Test:**
```bash
terraform init
terraform plan -var-file="./test/terraform.tfvars"
terraform apply -var-file="./test/terraform.tfvars"
```

**Production:**
```bash
terraform init
terraform plan -var-file="./prod/terraform.tfvars"
terraform apply -var-file="./prod/terraform.tfvars"
```

## Shared Root Configuration Files

### provider.tf
### variables.tf
Defines all input variables that are then customized per environment in terraform.tfvars
### main.tf
Defines all AWS resources:
- VPC with DNS enabled
- Public Subnet
- Internet Gateway
- Route Table with internet route
- Security Group (SSH, HTTP, HTTPS)
- EC2 Instance
### outputs.tf
Defines outputs: VPC ID, Subnet ID, Instance ID, Public/Private IPs, Security Group ID

## Common Terraform Commands
bash

# Initialize (run from root directory once)
terraform init

# Format and validate code
terraform fmt
terraform validate

# Plan changes for a specific environment
terraform plan -var-file="./dev/terraform.tfvars"

# Apply changes for a specific environment
terraform apply -var-file="./dev/terraform.tfvars"

# Show all resources in state
terraform state list

# Get output values
terraform output

# Get specific output value
terraform output vpc_id

# Destroy resources (be careful!)
terraform destroy -var-file="./dev/terraform.tfvars"


## Workflow Example
bash

# 1. Initialize (one time from root)
terraform init

# 2. Develop and test in 'dev' environment
terraform plan -var-file="./dev/terraform.tfvars"
terraform apply -var-file="./dev/terraform.tfvars"

# 3. Promote to 'test' environment
terraform plan -var-file="./test/terraform.tfvars"
terraform apply -var-file="./test/terraform.tfvars"

# 4. Deploy to 'production'
terraform plan -var-file="./prod/terraform.tfvars"
terraform apply -var-file="./prod/terraform.tfvars"

# 5. View outputs
terraform output


## Tips & Best Practices

✅ **Always run `terraform plan` before `terraform apply`**
✅ **Use the deployment scripts for consistency**
✅ **Keep all .tf files in version control**
✅ **Don't store `terraform.tfvars` files in version control if they contain secrets**
✅ **Review terraform.tfvars diff before applying to prod**
✅ **Use descriptive variable names**
✅ **Keep environments isolated with unique CIDR blocks**

## Troubleshooting

**Problem:** "Backend state conflict" 
- Solution: Each environment has separate tfstate, no conflicts expected

**Problem:** "Variable not defined"
- Solution: Check if terraform.tfvars exists in environment folder and is in correct format

**Problem:** "Wrong resources being modified"
- Solution: Always verify `-var-file` path is correct before running apply

**Problem:** "Module not found"
- Solution: Run `terraform init` from root directory to download all providers

