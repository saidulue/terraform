The Solution: Separate State Files Per Environment
1.Create a terraform.tfvars file for each environment:
# Directory structure:
3_Custom_var_configuration/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── terraform.tfvars
├── test/
│   └── terraform.tfvars
└── prod/
    └── terraform.tfvars

2. OR use Terraform workspaces:

# Create separate workspaces
terraform workspace new dev
terraform workspace new test
terraform workspace new prod

# Switch between environments
terraform workspace select dev
terraform apply -var-file="dev.tfvars"

terraform workspace select prod
terraform apply -var-file="prod.tfvars"

3. OR use different directories with separate state:

cd 3_Custom_var_configuration/dev
terraform init
terraform apply -var-file="../dev.tfvars"

cd ../prod
terraform init
terraform apply -var-file="../prod.tfvars"

