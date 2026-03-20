terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "my-terraform-state-simple-lock"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # Simple S3 state protection:
    # - Versioning enabled (recovery capability)
    # - Encryption enabled (data at rest)
    # - Bucket policy prevents unauthorized deletion
    # - Public access blocked
  }
}
