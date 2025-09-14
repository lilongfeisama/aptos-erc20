param(
    [Parameter(Mandatory=$false)]
    [string]$TestFilter = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

Write-Host "Running Move tests..." -ForegroundColor Green

# Get the parent directory of the script directory as the package directory
$PackageDir = Split-Path -Parent $PSScriptRoot

# Build the test command
$TestArgs = @("move", "test")

if ($TestFilter) {
    $TestArgs += "--filter"
    $TestArgs += $TestFilter
    Write-Host "Test Filter: $TestFilter" -ForegroundColor Cyan
}

if ($Verbose) {
    $TestArgs += "--verbose"
    Write-Host "Verbose mode enabled" -ForegroundColor Cyan
}

$TestArgs += "--package-dir"
$TestArgs += $PackageDir

try {
    Write-Host "Executing: aptos $($TestArgs -join ' ')" -ForegroundColor Yellow
    
    # Execute aptos move test command
    & aptos @TestArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nAll tests passed successfully!" -ForegroundColor Green
    } else {
        Write-Host "`nTests failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error occurred during testing: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nTest execution completed." -ForegroundColor Blue