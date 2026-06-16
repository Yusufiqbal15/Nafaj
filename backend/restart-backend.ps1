# Backend Restart Script
# This will kill old Node processes and start fresh backend

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  BACKEND RESTART SCRIPT" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop all Node processes
Write-Host "Step 1: Stopping all Node.js processes..." -ForegroundColor Yellow
try {
    $nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
    if ($nodeProcesses) {
        Write-Host "   Found $($nodeProcesses.Count) Node.js process(es)" -ForegroundColor Gray
        Stop-Process -Name node -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "   ✓ All Node processes stopped" -ForegroundColor Green
    } else {
        Write-Host "   No Node processes running" -ForegroundColor Gray
    }
} catch {
    Write-Host "   Warning: Could not stop processes" -ForegroundColor Red
}

Write-Host ""

# Step 2: Wait a moment
Write-Host "Step 2: Waiting for cleanup..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "   ✓ Ready" -ForegroundColor Green

Write-Host ""

# Step 3: Start backend
Write-Host "Step 3: Starting backend server..." -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  BACKEND SERVER STARTING" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Start backend server
node src/server.js
