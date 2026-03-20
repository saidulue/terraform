#!/bin/bash

# Script to deploy Terraform configurations for different environments
# Usage: ./deploy.sh [dev|test|prod] [plan|apply|destroy]

set -e

ENVIRONMENT=$1
ACTION=${2:-plan}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 [dev|test|prod] [plan|apply|destroy]"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan      # Plan dev resources"
    echo "  $0 dev apply     # Deploy dev resources"
    echo "  $0 dev destroy  # Destroy dev resources"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo "Error: Environment must be dev, test, or prod"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    echo "Error: Action must be plan, apply, or destroy"
    exit 1
fi

TFVARS_FILE="$ENVIRONMENT/terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "Error: $TFVARS_FILE not found"
    exit 1
fi

echo "=================================================="
echo "Terraform $ACTION for $ENVIRONMENT environment"
echo "Using variables from: $TFVARS_FILE"
echo "=================================================="
echo ""

terraform init
terraform "$ACTION" -var-file="$TFVARS_FILE"

echo ""
echo "=================================================="
echo "Complete!"
echo "=================================================="
