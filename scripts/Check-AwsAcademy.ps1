# Read-only connection check for the AWS Academy CLI profile.
param(
    [string]$Profile = "academy",
    [string]$Region = "us-east-1",
    [string]$ExpectedAccount = "007712891456"
)
$ErrorActionPreference = "Stop"
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI not found. Follow docs/aws-cli-setup-windows.md."
}
Write-Host "AWS CLI:" -ForegroundColor Cyan
aws --version
Write-Host "Credential source (keys masked):" -ForegroundColor Cyan
aws configure list --profile $Profile
if ($LASTEXITCODE -ne 0) { throw "AWS profile is not usable." }

Write-Host "Caller identity:" -ForegroundColor Cyan
$identityText = aws sts get-caller-identity --profile $Profile --region $Region --output json
if ($LASTEXITCODE -ne 0) {
    throw "Authentication failed; refresh the AWS Academy session credentials."
}
$identity = $identityText | ConvertFrom-Json
Write-Host ("Account: {0}" -f $identity.Account)
Write-Host ("ARN:     {0}" -f $identity.Arn)
if ($identity.Account -ne $ExpectedAccount) {
    throw "Wrong AWS account for this project. No changes were made."
}
Write-Host "Connected to expected AWS Academy account." -ForegroundColor Green
