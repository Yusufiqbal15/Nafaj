# Kill and Restart Backend Server

Write-Host "Stopping old backend server..." -ForegroundColor Yellow

# Kill all node processes
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "✓ Old server stopped" -ForegroundColor Green

# Wait a moment
Start-Sleep -Seconds 2

Write-Host "`nStarting new backend server..." -ForegroundColor Yellow

# Start server
npm start
