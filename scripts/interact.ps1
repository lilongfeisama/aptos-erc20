param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$Profile = "testnet",
    
    [Parameter(Mandatory=$false)]
    [string]$Recipient = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Amount = "0"
)

# Contract address (your deployed contract)
$ContractAddress = "0x35196d99ae6fed94c5133eb2bed70c87600f9b39e6e5912c2b0231c5fbf4d318"

Write-Host "Interacting with ERC20 contract at: $ContractAddress" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Cyan
Write-Host "Profile: $Profile" -ForegroundColor Cyan

switch ($Action.ToLower()) {
    "initialize" {
        Write-Host "Initializing ERC20 token..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::initialize" --profile $Profile
    }
    
    "register" {
        Write-Host "Registering account to receive tokens..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::register" --profile $Profile
    }
    
    "mint" {
        if (-not $Recipient -or $Amount -eq "0") {
            Write-Host "Usage: .\interact.ps1 -Action mint -Recipient <address> -Amount <amount>" -ForegroundColor Red
            exit 1
        }
        Write-Host "Minting $Amount tokens to $Recipient..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::mint" --args address:$Recipient u64:$Amount --profile $Profile
    }
    
    "transfer" {
        if (-not $Recipient -or $Amount -eq "0") {
            Write-Host "Usage: .\interact.ps1 -Action transfer -Recipient <address> -Amount <amount>" -ForegroundColor Red
            exit 1
        }
        Write-Host "Transferring $Amount tokens to $Recipient..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::transfer" --args address:$Recipient u64:$Amount --profile $Profile
    }
    
    "burn" {
        if ($Amount -eq "0") {
            Write-Host "Usage: .\interact.ps1 -Action burn -Amount <amount>" -ForegroundColor Red
            exit 1
        }
        Write-Host "Burning $Amount tokens..." -ForegroundColor Yellow
        aptos move run --function-id "${ContractAddress}::erc20::burn" --args u64:$Amount --profile $Profile
    }
    
    "balance" {
        if (-not $Recipient) {
            # Get current account address if no recipient specified
            $AccountInfo = aptos account list --profile $Profile | ConvertFrom-Json
            $Recipient = $AccountInfo.Result[0]
        }
        Write-Host "Checking balance for: $Recipient" -ForegroundColor Yellow
        aptos move view --function-id "${ContractAddress}::erc20::balance" --args address:$Recipient --profile $Profile
    }
    
    "help" {
        Write-Host "Available actions:" -ForegroundColor Green
        Write-Host "  initialize                         - Initialize the token (owner only, run once)" -ForegroundColor White
        Write-Host "  register                           - Register account to receive tokens" -ForegroundColor White
        Write-Host "  mint -Recipient <addr> -Amount <n> - Mint tokens to recipient" -ForegroundColor White
        Write-Host "  transfer -Recipient <addr> -Amount <n> - Transfer tokens to recipient" -ForegroundColor White
        Write-Host "  burn -Amount <n>                   - Burn tokens from your account" -ForegroundColor White
        Write-Host "  balance [-Recipient <addr>]        - Check balance (defaults to your account)" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "Examples:" -ForegroundColor Green
        Write-Host "  .\interact.ps1 -Action initialize" -ForegroundColor Gray
        Write-Host "  .\interact.ps1 -Action register" -ForegroundColor Gray
        Write-Host "  .\interact.ps1 -Action mint -Recipient 0x123 -Amount 1000" -ForegroundColor Gray
        Write-Host "  .\interact.ps1 -Action balance" -ForegroundColor Gray
        Write-Host "  .\interact.ps1 -Action transfer -Recipient 0x456 -Amount 100" -ForegroundColor Gray
    }
    
    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Use -Action help to see available actions" -ForegroundColor Yellow
    }
}