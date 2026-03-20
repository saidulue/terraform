#!/bin/bash

# S3 Bucket Setup with Simple State Protection (Versioning + Encryption + Policies)
# Creates S3 bucket with versioning and bucket policy for state file protection

set -e

AWS_REGION="us-east-1"
BUCKET_NAME="my-terraform-state-simple-lock"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=========================================="
echo "Creating S3 Backend with Simple Lock"
echo "=========================================="
echo ""

# Create S3 Bucket
echo "[1/5] Creating S3 bucket..."
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "    ✓ S3 bucket already exists"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region $AWS_REGION
    echo "    ✓ S3 bucket created"
fi

# Enable Versioning (for recovery and protection)
echo "[2/5] Enabling S3 versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "    ✓ Versioning enabled"

# Enable Encryption
echo "[3/5] Enabling S3 encryption..."
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
echo "[4/5] Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "    ✓ Public access blocked"

# Apply bucket policy to prevent unauthorized deletion
echo "[5/5] Applying bucket policy for state protection..."
POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforcedTLS",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}",
        "arn:aws:s3:::${BUCKET_NAME}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "PreventObjectDeletion",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*",
      "Condition": {
        "StringNotEquals": {
          "aws:userid": "*:terraform"
        }
      }
    },
    {
      "Sid": "PreventBucketDeletion",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:DeleteBucket",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}"
    }
  ]
}
EOF
)

aws s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy "$POLICY"
echo "    ✓ Bucket policy applied"

echo ""
echo "=========================================="
echo "✓ Backend setup complete!"
echo ""
echo "S3 Bucket: $BUCKET_NAME"
echo "State File: s3://$BUCKET_NAME/vpc/terraform.tfstate"
echo "Protection: Versioning + Encryption + Bucket Policy"
echo "Encryption: AES256"
echo "Versioning: Enabled (recovery capability)"
echo ""
echo "Ready to deploy!"
echo "=========================================="
