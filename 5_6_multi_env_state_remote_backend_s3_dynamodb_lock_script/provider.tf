terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote backend configuration
  # State file will be stored in S3 with unique path per environment
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    # key varies per environment - see deploy scripts
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}
