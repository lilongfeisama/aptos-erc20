param(
    [Parameter(Mandatory=$false)]
    [string]$Profile = "default"
)

# Default deployer address
$DeployerAddress = "0x35196d99ae6fed94c5133eb2bed70c87600f9b39e6e5912c2b0231c5fbf4d318"

Write-Host "Deploying ERC20 contract..." -ForegroundColor Green
Write-Host "Deployer Address: $DeployerAddress" -ForegroundColor Cyan
Write-Host "Profile: $Profile" -ForegroundColor Cyan

# Get the parent directory of the script directory as the package directory
$PackageDir = Split-Path -Parent $PSScriptRoot

try {
    # Execute aptos move publish command
    aptos move publish `
        --package-dir "$PackageDir" `
        --named-addresses "token=$DeployerAddress" `
        --profile $Profile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Contract deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Contract deployment failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error occurred during deployment: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


# .\scripts\deploy.ps1 -Profile testnet