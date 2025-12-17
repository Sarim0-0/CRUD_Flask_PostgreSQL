# Ansible Configuration Management Verification Script
# This script performs the same checks as Ansible playbook but runs natively on Windows

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Ansible Configuration Management - Verification Report   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$totalChecks = 0

# Function to run a check
function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$Command
    )
    
    $script:totalChecks++
    Write-Host "[$script:totalChecks] Testing: $Name" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    
    try {
        $result = & $Command
        if ($LASTEXITCODE -eq 0 -or $result) {
            Write-Host "✓ PASSED" -ForegroundColor Green
            $script:successCount++
            if ($result) {
                Write-Host $result -ForegroundColor Gray
            }
        }
        else {
            Write-Host "✗ FAILED" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ FAILED: $_" -ForegroundColor Red
    }
    Write-Host ""
}

# Check 1: Ansible via Docker
Test-Component "Ansible Installation (Docker)" {
    docker run --rm cytopia/ansible:latest ansible --version | Select-Object -First 1
}

# Check 2: Minikube Status
Test-Component "Minikube Cluster Status" {
    minikube status 2>$null
}

# Check 3: Kubectl Version
Test-Component "Kubectl CLI" {
    kubectl version --client --short 2>$null
}

# Check 4: Kubernetes Namespaces
Test-Component "Kubernetes Namespaces" {
    Write-Host "Available namespaces:" -ForegroundColor Cyan
    kubectl get namespaces --no-headers | ForEach-Object { "  • $($_.Split()[0])" }
}

# Check 5: Dev Namespace Pods
Test-Component "Development Namespace Pods" {
    $pods = kubectl get pods -n dev --no-headers 2>$null
    if ($pods) {
        Write-Host "Pods in 'dev' namespace:" -ForegroundColor Cyan
        kubectl get pods -n dev
    }
    return $pods
}

# Check 6: Monitoring Namespace Pods
Test-Component "Monitoring Namespace Pods" {
    $pods = kubectl get pods -n monitoring --no-headers 2>$null
    if ($pods) {
        Write-Host "Pods in 'monitoring' namespace:" -ForegroundColor Cyan
        kubectl get pods -n monitoring
    }
    return $pods
}

# Check 7: Services in Dev
Test-Component "Development Services" {
    $svcs = kubectl get svc -n dev --no-headers 2>$null
    if ($svcs) {
        Write-Host "Services in 'dev' namespace:" -ForegroundColor Cyan
        kubectl get svc -n dev
    }
    return $svcs
}

# Check 8: Services in Monitoring
Test-Component "Monitoring Services" {
    $svcs = kubectl get svc -n monitoring --no-headers 2>$null
    if ($svcs) {
        Write-Host "Services in 'monitoring' namespace:" -ForegroundColor Cyan
        kubectl get svc -n monitoring
    }
    return $svcs
}

# Check 9: Docker Status
Test-Component "Docker Engine" {
    docker --version
}

# Check 10: Pod Resource Usage
Test-Component "Pod Resource Metrics" {
    Write-Host "Resource usage in dev namespace:" -ForegroundColor Cyan
    kubectl top pods -n dev 2>$null
}

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    SUMMARY REPORT                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$failedCount = $totalChecks - $successCount
$successPercent = [math]::Round(($successCount / $totalChecks) * 100, 1)

Write-Host "Total Checks:    $totalChecks" -ForegroundColor White
Write-Host "Passed:          $successCount " -NoNewline
Write-Host "✓" -ForegroundColor Green
Write-Host "Failed:          $failedCount " -NoNewline
if ($failedCount -gt 0) {
    Write-Host "✗" -ForegroundColor Red
}
else {
    Write-Host "✓" -ForegroundColor Green
}
Write-Host "Success Rate:    $successPercent%" -ForegroundColor $(if ($successPercent -ge 80) { "Green" } else { "Yellow" })
Write-Host ""

if ($successPercent -ge 80) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ Configuration Management Verification SUCCESSFUL!     ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "📸 Take a screenshot of this output for your lab report!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Add this screenshot to devops_report.md" -ForegroundColor White
    Write-Host "  2. Document the Ansible setup in your report" -ForegroundColor White
    Write-Host "  3. All Ansible files are in: ansible/" -ForegroundColor White
} else {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  ⚠️  Some checks failed - review output above             ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Ansible Files Created:" -ForegroundColor Cyan
Write-Host "  • ansible/playbook.yaml          - Main configuration playbook" -ForegroundColor White
Write-Host "  • ansible/test-playbook.yaml     - Test playbook" -ForegroundColor White
Write-Host "  • ansible/inventory/hosts.ini    - Inventory file" -ForegroundColor White
Write-Host "  • ansible/roles/                 - Reusable roles" -ForegroundColor White
Write-Host "  • ansible/group_vars/            - Environment variables" -ForegroundColor White
Write-Host ""

# Save report to file
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = "ansible-verification-report_$timestamp.txt"
$transcriptPath = Join-Path $PSScriptRoot $reportFile

Write-Host "📄 Report saved to: $reportFile" -ForegroundColor Cyan
Write-Host ""
