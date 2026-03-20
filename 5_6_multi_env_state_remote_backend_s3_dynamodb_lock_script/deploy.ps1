# PowerShell script for multi-environment deployment
# Usage: .\deploy.ps1 -Environment dev -Action plan

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev', 'test', 'prod')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'plan', 'apply', 'destroy')]
    [string]$Action = 'plan'
)

$TfvarsFile = "$Environment/terraform.tfvars"

if (-not (Test-Path $TfvarsFile)) {
    Write-Error "Error: $TfvarsFile not found"
    exit 1
}

$AccountId = (aws sts get-caller-identity --query Account --output text)
$BucketName = "my-terraform-state-bucket-$AccountId"

Write-Output "=================================================="
Write-Output "Terraform $Action for $Environment environment"
Write-Output "Using variables from: $TfvarsFile"
Write-Output "Remote state: s3://$BucketName/$Environment/terraform.tfstate"
Write-Output "=================================================="
Write-Output ""

if ($Action -eq 'init') {
    terraform init `
        -backend-config="bucket=$BucketName" `
        -backend-config="key=$Environment/terraform.tfstate" `
        -backend-config="region=us-east-1" `
        -backend-config="dynamodb_table=terraform-locks"
} else {
    terraform $Action -var-file="$TfvarsFile"
}

Write-Output ""
Write-Output "=================================================="
Write-Output "Complete!"
Write-Output "=================================================="
