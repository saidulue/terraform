terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 backend with Object Lock (no DynamoDB)
  backend "s3" {
    bucket  = "my-terraform-state-s3-locked"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # S3 Object Lock protects state files from deletion/modification
  }
}
