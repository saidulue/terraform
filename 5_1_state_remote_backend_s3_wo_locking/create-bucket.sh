#!/bin/bash

# Simple S3 Bucket Setup (No DynamoDB Locking)
# Creates only an S3 bucket for remote state

set -e

AWS_REGION="us-east-1"
BUCKET_NAME="my-terraform-state-simple"

echo "=========================================="
echo "Creating Simple S3 Remote State Bucket"
echo "=========================================="
echo ""

# Create S3 Bucket
echo "[1/3] Creating S3 bucket..."
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "    ✓ S3 bucket already exists"
else
    aws s3 mb "s3://$BUCKET_NAME" --region $AWS_REGION
    echo "    ✓ S3 bucket created"
fi

# Enable Versioning
echo "[2/3] Enabling S3 versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "    ✓ Versioning enabled"

# Enable Encryption
echo "[3/3] Enabling S3 encryption..."
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

echo ""
echo "=========================================="
echo "✓ Backend setup complete!"
echo ""
echo "Bucket Name: $BUCKET_NAME"
echo "State File Location: s3://$BUCKET_NAME/vpc/terraform.tfstate"
echo ""
echo "Ready to deploy!"
echo "=========================================="
