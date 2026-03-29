terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend with dynamic path configuration
  # Path is overridden per environment via: terraform init -backend-config="path=$ENVIRONMENT/terraform.tfstate"
  backend "local" {
    path = "terraform.tfstate"
  }
}
