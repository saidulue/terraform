3_Custom_var_configuration/
|__ main.tf              # VPC, subnet, security group, and EC2 instance
|__ variables.tf         # All input variables with validation
|__ outputs.tf           # Output values (IDs, IPs, etc.)
|__ provider.tf          # AWS provider configuration
|__ dev.tfvars           # Development environment values
|__ test.tfvars          # Testing environment values
|__ prod.tfvars          # Production environment values

How to Deploy:
Development:
------------
cd d:\NIT_AWS_Practice\GIT_WORKSPACE\terraform\3_Custom_var_configuration

terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

Testing:
------------
terraform plan -var-file="test.tfvars"
terraform apply -var-file="test.tfvars"

Production:
------------
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"

Environment Differences:
------------------------
Component	            Dev	           Test	            Prod
VPC CIDR	        10.0.0.0/16	    10.1.0.0/16	    10.2.0.0/16
Instance Type	    t2.micro	    t2.small	    t2.medium
Availability Zone	us-east-1a	us-east-1b	us-east-1c
Resource Names	    dev-vpc, dev-web-server	test-vpc, test-web-server	prod-vpc, prod-web-server

Resources Created:
------------------
✅ VPC with DNS enabled
✅ Public subnet
✅ Internet Gateway
✅ Route Table
✅ Security Group (SSH, HTTP, HTTPS)
✅ EC2 Instance

Outputs:
--------
After deployment, you'll get:

VPC ID & CIDR
Subnet ID & CIDR
EC2 Instance ID, Public IP, Private IP
Security Group ID
Environment name

Note LIMITATONS: With this approach we can create one environment only. eithr dev/test/prod
----------------
Ex: 1.  First created a 'dev' environment. Statefile created at this time
    2.  Now if you want to create 'test' environment, As the state file is present, it will read the statefile and try to create 'test' environment by update/delete the dev resources 
    3.  
