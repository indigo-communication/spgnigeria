# Quick SSL Server Launcher for Matrixbs
# Double-click this file or run: .\start.ps1

$SSLCert = "C:\ssl\localhost+2.pem"
$SSLKey = "C:\ssl\localhost+2-key.pem"
$Port = 8080

Write-Host "Starting Matrixbs with SSL..." -ForegroundColor Green

# Stop existing servers
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start server in minimized window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "http-server -S -C '$SSLCert' -K '$SSLKey' -p $Port" -WindowStyle Minimized

Start-Sleep -Seconds 3

# Open browser
Start-Process chrome -ArgumentList "https://127.0.0.1:$Port/index_local.html"

Write-Host "Server running at https://127.0.0.1:$Port" -ForegroundColor Green
