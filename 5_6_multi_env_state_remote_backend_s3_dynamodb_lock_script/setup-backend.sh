#!/bin/bash

# Multi-Environment Backend Configuration Script
# Creates S3 bucket and DynamoDB table for Terraform remote state

set -e

AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="my-terraform-state-bucket-${ACCOUNT_ID}"
DYNAMODB_TABLE="terraform-locks"

echo "=========================================="
echo "Creating Terraform Remote State Backend"
echo "=========================================="
echo ""
echo "Account ID: $ACCOUNT_ID"
echo "Bucket Name: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo ""

# Create S3 Bucket
echo "[1/6] Creating S3 bucket..."
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "    ✓ S3 bucket already exists"
else
    aws s3 mb "s3://$BUCKET_NAME" --region $AWS_REGION
    echo "    ✓ S3 bucket created"
fi

# Enable Versioning
echo "[2/6] Enabling S3 versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "    ✓ Versioning enabled"

# Enable Encryption
echo "[3/6] Enabling S3 encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
echo "    ✓ Encryption enabled"

# Block Public Access
echo "[4/6] Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "    ✓ Public access blocked"

# Create DynamoDB Table
echo "[5/6] Creating DynamoDB table..."
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region $AWS_REGION 2>/dev/null; then
    echo "    ✓ DynamoDB table already exists"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $AWS_REGION
    echo "    ✓ DynamoDB table created"
fi

echo "[6/6] Summary"
echo "=========================================="
echo "✓ Backend setup complete!"
echo ""
echo "Update provider.tf with:"
echo ""
echo "  bucket = \"$BUCKET_NAME\""
echo ""
echo "Environment state paths:"
echo "  - dev:  s3://$BUCKET_NAME/dev/terraform.tfstate"
echo "  - test: s3://$BUCKET_NAME/test/terraform.tfstate"
echo "  - prod: s3://$BUCKET_NAME/prod/terraform.tfstate"
echo ""
echo "=========================================="
