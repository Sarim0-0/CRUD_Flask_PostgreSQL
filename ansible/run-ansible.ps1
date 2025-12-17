# PowerShell script to run Ansible via Docker (Windows-compatible)
# Usage: .\run-ansible.ps1 [playbook-name] [extra-args]
# Example: .\run-ansible.ps1 test-playbook.yaml
# Example: .\run-ansible.ps1 playbook.yaml "-i inventory/hosts.ini"

param(
    [Parameter(Mandatory=$false)]
    [string]$Playbook = "test-playbook.yaml",
    
    [Parameter(Mandatory=$false)]
    [string]$ExtraArgs = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Ansible via Docker Container" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Playbook: $Playbook" -ForegroundColor Yellow
Write-Host ""

# Check if Docker is running
$dockerRunning = docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Get the current directory (ansible folder)
$currentDir = Get-Location
$workspaceRoot = Split-Path $currentDir -Parent

Write-Host "Running Ansible playbook..." -ForegroundColor Green
Write-Host ""

# Run Ansible in Docker with proper volume mounts
if ($ExtraArgs) {
    docker run --rm -it `
        -v "${workspaceRoot}:/work" `
        -w /work/ansible `
        --network host `
        cytopia/ansible:latest `
        ansible-playbook $Playbook $ExtraArgs
} else {
    docker run --rm -it `
        -v "${workspaceRoot}:/work" `
        -w /work/ansible `
        --network host `
        cytopia/ansible:latest `
        ansible-playbook $Playbook
}

$exitCode = $LASTEXITCODE

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ Ansible playbook completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "❌ Ansible playbook failed with exit code: $exitCode" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
}

exit $exitCode
