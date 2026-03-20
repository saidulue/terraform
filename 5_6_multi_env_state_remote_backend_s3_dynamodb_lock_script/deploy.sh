#!/bin/bash

# Multi-Environment Deployment Script
# Usage: ./deploy.sh [dev|test|prod] [init|plan|apply|destroy]

set -e

ENVIRONMENT=$1
ACTION=${2:-plan}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 [dev|test|prod] [init|plan|apply|destroy]"
    echo ""
    echo "Examples:"
    echo "  $0 dev init        # Initialize dev backend"
    echo "  $0 dev plan        # Plan dev resources"
    echo "  $0 dev apply       # Deploy dev resources"
    echo "  $0 prod destroy    # Destroy prod resources"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo "Error: Environment must be dev, test, or prod"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(init|plan|apply|destroy)$ ]]; then
    echo "Error: Action must be init, plan, apply, or destroy"
    exit 1
fi

TFVARS_FILE="$ENVIRONMENT/terraform.tfvars"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="my-terraform-state-bucket-${ACCOUNT_ID}"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "Error: $TFVARS_FILE not found"
    exit 1
fi

echo "=================================================="
echo "Terraform $ACTION for $ENVIRONMENT environment"
echo "Using variables from: $TFVARS_FILE"
echo "Remote state: s3://$BUCKET_NAME/$ENVIRONMENT/terraform.tfstate"
echo "=================================================="
echo ""

if [ "$ACTION" = "init" ]; then
    terraform init \
        -backend-config="bucket=$BUCKET_NAME" \
        -backend-config="key=$ENVIRONMENT/terraform.tfstate" \
        -backend-config="region=us-east-1" \
        -backend-config="dynamodb_table=terraform-locks"
else
    terraform "$ACTION" -var-file="$TFVARS_FILE"
fi

echo ""
echo "=================================================="
echo "Complete!"
echo "=================================================="
