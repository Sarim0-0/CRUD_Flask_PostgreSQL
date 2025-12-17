# Quick script to run the test playbook
# This verifies your Kubernetes and Docker setup

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Ansible Test Playbook" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will verify:" -ForegroundColor Yellow
Write-Host "  ✓ Ansible setup" -ForegroundColor Green
Write-Host "  ✓ Minikube status" -ForegroundColor Green
Write-Host "  ✓ Kubernetes pods and services" -ForegroundColor Green
Write-Host "  ✓ Docker installation" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
$dockerRunning = docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Get the workspace root
$currentDir = Get-Location
$workspaceRoot = Split-Path $currentDir -Parent

Write-Host "Starting Ansible in Docker container..." -ForegroundColor Green
Write-Host ""

# Run the test playbook with Windows kubectl access
docker run --rm -it `
    -v "${workspaceRoot}:/work" `
    -e "KUBECONFIG=/work/.kube-config" `
    -w /work/ansible `
    --network host `
    cytopia/ansible:latest `
    sh -c "apk add --no-cache kubectl && ansible-playbook test-playbook.yaml -v"

$exitCode = $LASTEXITCODE

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($exitCode -eq 0) {
    Write-Host "✅ Test completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Take a screenshot of the output above" -ForegroundColor White
    Write-Host "2. Add it to your devops_report.md" -ForegroundColor White
    Write-Host "3. Run the full playbook if needed:" -ForegroundColor White
    Write-Host "   .\run-ansible.ps1 playbook.yaml '-i inventory/hosts.ini'" -ForegroundColor Cyan
} else {
    Write-Host "❌ Test failed with exit code: $exitCode" -ForegroundColor Red
    Write-Host "Check the output above for errors" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

exit $exitCode
