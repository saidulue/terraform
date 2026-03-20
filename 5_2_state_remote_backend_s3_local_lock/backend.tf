terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Phase 1: Local backend (S3 resources are created by Terraform in main.tf)
  # After first apply, migrate to S3 backend (see instructions below)
  backend "local" {
    path = "terraform.tfstate"
  }

  # To migrate to S3 backend after resources exist:
  # 1. Uncomment the S3 backend block below
  # 2. Run: terraform init -migrate-state
  
  # backend "s3" {
  #   bucket  = "my-terraform-state-bare-minimum"
  #   key     = "vpc/terraform.tfstate"
  #   region  = "us-east-1"
  #   encrypt = true
  # }
}
