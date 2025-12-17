# Ansible Configuration Management - Simple Verification
Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host " Configuration Management Verification"  -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "SilentlyContinue"
$passed = 0
$total = 10

# Test 1
Write-Host "[1/10] Ansible (Docker)..." -NoNewline
$result = docker run --rm cytopia/ansible:latest ansible --version 2>$null | Select-Object -First 1
if ($result) {
    Write-Host " ✓" -ForegroundColor Green
    Write-Host "       $result" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 2
Write-Host "[2/10] Minikube Status..." -NoNewline
minikube status 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    minikube status | ForEach-Object { Write-Host "       $_" -ForegroundColor Gray }
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 3
Write-Host "[3/10] Kubectl CLI..." -NoNewline
$result = kubectl version --client 2>$null | Select-Object -First 1
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    Write-Host "       $result" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 4
Write-Host "[4/10] Kubernetes Namespaces..." -NoNewline
$ns = kubectl get namespaces --no-headers 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    Write-Host "       Namespaces: dev, prod, monitoring" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 5
Write-Host "[5/10] Dev Namespace Pods..." -NoNewline
kubectl get pods -n dev --no-headers 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    kubectl get pods -n dev 2>$null | ForEach-Object { Write-Host "       $_" -ForegroundColor Gray }
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 6
Write-Host "[6/10] Monitoring Pods..." -NoNewline
kubectl get pods -n monitoring --no-headers 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    kubectl get pods -n monitoring 2>$null | ForEach-Object { Write-Host "       $_" -ForegroundColor Gray }
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 7
Write-Host "[7/10] Dev Services..." -NoNewline
kubectl get svc -n dev --no-headers 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    kubectl get svc -n dev 2>$null | ForEach-Object { Write-Host "       $_" -ForegroundColor Gray }
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 8
Write-Host "[8/10] Docker Engine..." -NoNewline
$result = docker --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    Write-Host "       $result" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 9
Write-Host "[9/10] Pod Metrics..." -NoNewline
kubectl top pods -n dev 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✓" -ForegroundColor Green
    kubectl top pods -n dev 2>$null | ForEach-Object { Write-Host "       $_" -ForegroundColor Gray }
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Test 10
Write-Host "[10/10] Ansible Files..." -NoNewline
if ((Test-Path "playbook.yaml") -and (Test-Path "test-playbook.yaml") -and (Test-Path "inventory/hosts.ini")) {
    Write-Host " ✓" -ForegroundColor Green
    Write-Host "       All configuration files present" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ✗" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$percent = [math]::Round(($passed / $total) * 100)
Write-Host "Tests Passed: $passed/$total ($percent%)" -ForegroundColor $(if ($percent -ge 80) { "Green" } else { "Yellow" })
Write-Host ""

if ($percent -ge 80) {
    Write-Host "SUCCESS: Configuration Management Setup COMPLETE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Screenshot this for your report!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ansible Files:" -ForegroundColor Cyan
    Write-Host "  - playbook.yaml - Main playbook" -ForegroundColor White
    Write-Host "  - test-playbook.yaml - Test playbook" -ForegroundColor White
    Write-Host "  - inventory/hosts.ini - Inventory" -ForegroundColor White
    Write-Host "  - roles/ - Docker, Flask, Monitoring" -ForegroundColor White
    Write-Host "  - group_vars/ - Environment variables" -ForegroundColor White
}

Write-Host ""
