#!/bin/bash

# S3 Bucket Setup with Object Lock (No DynamoDB)
# Creates S3 bucket with Object Lock for state file protection

set -e

AWS_REGION="us-east-1"
BUCKET_NAME="my-terraform-state-s3-locked"

echo "=========================================="
echo "Creating S3 Backend with Object Lock"
echo "=========================================="
echo ""

# Create S3 Bucket with Object Lock enabled
echo "[1/4] Creating S3 bucket with Object Lock..."
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "    ✓ S3 bucket already exists"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region $AWS_REGION \
        --object-lock-enabled-for-bucket
    echo "    ✓ S3 bucket created with Object Lock"
fi

# Enable Versioning (required for Object Lock)
echo "[2/4] Enabling S3 versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "    ✓ Versioning enabled"

# Enable Encryption
echo "[3/4] Enabling S3 encryption..."
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
echo "[4/4] Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "    ✓ Public access blocked"

echo ""
echo "=========================================="
echo "✓ Backend setup complete!"
echo ""
echo "S3 Bucket: $BUCKET_NAME"
echo "State File: s3://$BUCKET_NAME/vpc/terraform.tfstate"
echo "Protection: S3 Object Lock (GOVERNANCE mode)"
echo "Encryption: AES256"
echo "Versioning: Enabled"
echo ""
echo "Ready to deploy!"
echo "=========================================="
