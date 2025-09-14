# Quick interaction script for common operations
param(
    [Parameter(Mandatory=$false)]
    [string]$Profile = "testnet"
)

$ContractAddress = "0x35196d99ae6fed94c5133eb2bed70c87600f9b39e6e5912c2b0231c5fbf4d318"

Write-Host "=== ERC20 Contract Quick Actions ===" -ForegroundColor Green
Write-Host "Contract: $ContractAddress" -ForegroundColor Cyan
Write-Host "Profile: $Profile" -ForegroundColor Cyan
Write-Host ""

# Get current account address
try {
    $AccountInfo = aptos account list --profile $Profile | ConvertFrom-Json
    $MyAddress = $AccountInfo.Result[0]
    Write-Host "Your address: $MyAddress" -ForegroundColor Yellow
} catch {
    Write-Host "Error getting account info. Make sure profile '$Profile' exists." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Choose an action:" -ForegroundColor Green
Write-Host "1. Initialize token (owner only, run once)" -ForegroundColor White
Write-Host "2. Register account" -ForegroundColor White
Write-Host "3. Check my balance" -ForegroundColor White
Write-Host "4. Mint tokens (owner only)" -ForegroundColor White
Write-Host "5. Transfer tokens" -ForegroundColor White
Write-Host "6. Burn tokens" -ForegroundColor White
Write-Host "0. Exit" -ForegroundColor White

$choice = Read-Host "Enter choice (0-6)"

switch ($choice) {
    "1" {
        Write-Host "Initializing token..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::initialize" --profile $Profile
    }
    
    "2" {
        Write-Host "Registering account..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::register" --profile $Profile
    }
    
    "3" {
        Write-Host "Checking balance..." -ForegroundColor Yellow
        aptos move view --function-id "${ContractAddress}::erc20::balance" --args address:$MyAddress --profile $Profile
    }
    
    "4" {
        $recipient = Read-Host "Enter recipient address (or press Enter for your address)"
        if (-not $recipient) { $recipient = $MyAddress }
        $amount = Read-Host "Enter amount to mint"
        
        Write-Host "Minting $amount tokens to $recipient..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::mint" --args address:$recipient u64:$amount --profile $Profile
    }
    
    "5" {
        $recipient = Read-Host "Enter recipient address"
        $amount = Read-Host "Enter amount to transfer"
        
        Write-Host "Transferring $amount tokens to $recipient..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::transfer" --args address:$recipient u64:$amount --profile $Profile
    }
    
    "6" {
        $amount = Read-Host "Enter amount to burn"
        
        Write-Host "Burning $amount tokens..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::burn" --args u64:$amount --profile $Profile
    }
    
    "0" {
        Write-Host "Goodbye!" -ForegroundColor Green
        exit 0
    }
    
    default {
        Write-Host "Invalid choice!" -ForegroundColor Red
    }
}