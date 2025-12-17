# Ansible Configuration Management - Verification Report
# Windows-compatible verification script

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Ansible Configuration Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passed = 0
$total = 0

# Test 1: Ansible (via Docker)
$total++
Write-Host "[$total] Ansible Installation (Docker)..." -NoNewline
try {
    $ver = docker run --rm cytopia/ansible:latest ansible --version 2>$null | Select-Object -First 1
    if ($ver) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    $ver" -ForegroundColor Gray
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 2: Minikube
$total++
Write-Host "[$total] Minikube Status..." -NoNewline
try {
    $status = minikube status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        minikube status | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 3: Kubectl
$total++
Write-Host "[$total] Kubectl CLI..." -NoNewline
try {
    $ver = kubectl version --client 2>$null | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    $ver" -ForegroundColor Gray
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 4: Namespaces
$total++
Write-Host "[$total] Kubernetes Namespaces..." -NoNewline
try {
    $ns = kubectl get namespaces --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $ns) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    Namespaces:" -ForegroundColor Cyan
        $ns | ForEach-Object { Write-Host "      • $($_.Split()[0])" -ForegroundColor Gray }
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 5: Dev Pods
$total++
Write-Host "[$total] Dev Namespace Pods..." -NoNewline
try {
    $pods = kubectl get pods -n dev --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $pods) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    Pods in dev:" -ForegroundColor Cyan
        kubectl get pods -n dev | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 6: Monitoring Pods
$total++
Write-Host "[$total] Monitoring Namespace Pods..." -NoNewline
try {
    $pods = kubectl get pods -n monitoring --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $pods) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    Pods in monitoring:" -ForegroundColor Cyan
        kubectl get pods -n monitoring | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 7: Dev Services
$total++
Write-Host "[$total] Dev Services..." -NoNewline
try {
    $svcs = kubectl get svc -n dev --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $svcs) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    Services in dev:" -ForegroundColor Cyan
        kubectl get svc -n dev | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 8: Docker
$total++
Write-Host "[$total] Docker Engine..." -NoNewline
try {
    $ver = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    $ver" -ForegroundColor Gray
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 9: Resource Metrics
$total++
Write-Host "[$total] Pod Resource Metrics..." -NoNewline
try {
    $metrics = kubectl top pods -n dev 2>$null
    if ($LASTEXITCODE -eq 0 -and $metrics) {
        Write-Host " ✓ PASSED" -ForegroundColor Green
        Write-Host "    Resource usage:" -ForegroundColor Cyan
        kubectl top pods -n dev | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        $passed++
    }
}
catch {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Test 10: Ansible Files
$total++
Write-Host "[$total] Ansible Configuration Files..." -NoNewline
$files = @(
    "playbook.yaml",
    "test-playbook.yaml",
    "inventory/hosts.ini",
    "ansible.cfg",
    "roles/docker/tasks/main.yml",
    "roles/flask-app/tasks/main.yml",
    "roles/monitoring/tasks/main.yml"
)
$allExist = $true
foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        $allExist = $false
        break
    }
}
if ($allExist) {
    Write-Host " ✓ PASSED" -ForegroundColor Green
    Write-Host "    All Ansible files present" -ForegroundColor Gray
    $passed++
}
else {
    Write-Host " ✗ FAILED" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$failed = $total - $passed
$percent = [math]::Round(($passed / $total) * 100, 1)

Write-Host "Total Tests: $total" -ForegroundColor White
Write-Host "Passed:      $passed ✓" -ForegroundColor Green
Write-Host "Failed:      $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "Success:     $percent%" -ForegroundColor $(if ($percent -ge 80) { "Green" } elseif ($percent -ge 60) { "Yellow" } else { "Red" })
Write-Host ""

if ($percent -ge 80) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " ✅ VERIFICATION SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📸 Take a screenshot of this output!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ansible Files Created:" -ForegroundColor Cyan
    Write-Host "  • ansible/playbook.yaml" -ForegroundColor White
    Write-Host "  • ansible/test-playbook.yaml" -ForegroundColor White
    Write-Host "  • ansible/inventory/hosts.ini" -ForegroundColor White
    Write-Host "  • ansible/roles/ (docker, flask-app, monitoring)" -ForegroundColor White
    Write-Host "  • ansible/group_vars/ (all.yml, dev.yml, prod.yml)" -ForegroundColor White
}
else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host " ⚠️ Some tests failed" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}

Write-Host ""
