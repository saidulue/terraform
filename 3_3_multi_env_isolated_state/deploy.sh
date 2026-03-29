#!/bin/bash

# ============================================
# Multi-Environment Terraform Deployment Script
# Each environment has isolated state file
# ============================================
# Usage: ./deploy.sh [dev|test|prod] [plan|apply|destroy]
# 
# Examples:
#   ./deploy.sh dev plan     # Plan dev resources
#   ./deploy.sh dev apply    # Deploy dev resources
#   ./deploy.sh test plan    # Plan test resources
#   ./deploy.sh prod destroy # Destroy prod resources

set -e

ENVIRONMENT=$1
ACTION=${2:-plan}

# ============================================
# Validation
# ============================================
if [ -z "$ENVIRONMENT" ]; then
    echo "❌ Usage: $0 [dev|test|prod] [plan|apply|destroy]"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan       # Plan dev environment"
    echo "  $0 dev apply      # Deploy dev environment"
    echo "  $0 test plan      # Plan test environment"
    echo "  $0 test apply     # Deploy test environment"
    echo "  $0 prod destroy   # Destroy prod environment"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo "❌ Error: Environment must be dev, test, or prod"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    echo "❌ Error: Action must be plan, apply, or destroy"
    exit 1
fi

# ============================================
# File Paths
# ============================================
TFVARS_FILE="$ENVIRONMENT/terraform.tfvars"
TFSTATE_FILE="$ENVIRONMENT/terraform.tfstate"
TFSTATE_BACKUP="$ENVIRONMENT/terraform.tfstate.backup"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "❌ Error: $TFVARS_FILE not found"
    exit 1
fi

# ============================================
# Display Configuration
# ============================================
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         Multi-Environment Terraform Deployment           ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Configuration:"
echo "   Environment:    $ENVIRONMENT"
echo "   Action:         $ACTION"
echo "   Variables:      $TFVARS_FILE"
echo "   State File:     $TFSTATE_FILE"
echo ""

# ============================================
# Initialize Terraform with Environment State
# ============================================
echo "🔧 Initializing Terraform for $ENVIRONMENT..."
terraform init \
  -backend-config="path=$TFSTATE_FILE" \
  -upgrade \
  -reconfigure > /dev/null 2>&1

echo "   ✓ Terraform initialized"
echo ""

# ============================================
# Execute Terraform Action
# ============================================
echo "⚙️  Running terraform $ACTION..."
echo "────────────────────────────────────────────────────────────"
echo ""

terraform "$ACTION" -var-file="$TFVARS_FILE"

echo ""
echo "────────────────────────────────────────────────────────────"

# ============================================
# Display Results
# ============================================
echo ""
if [ "$ACTION" = "destroy" ]; then
    echo "✓ Destroyed $ENVIRONMENT environment"
    echo "   State file: $TFSTATE_FILE (still preserved for history)"
elif [ "$ACTION" = "apply" ]; then
    echo "✓ Deployed $ENVIRONMENT environment"
    echo "   State file: $TFSTATE_FILE"
    echo ""
    echo "📊 Resources Created:"
    terraform state list | sed 's/^/   /'
else
    echo "✓ Planned $ENVIRONMENT environment"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║ Environment: $ENVIRONMENT | Action: $ACTION | Status: ✓ COMPLETE"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
