# Universal SSL Server Launcher
# Usage: .\start_ssl_server.ps1 [project_name] [port]
# Example: .\start_ssl_server.ps1 matrixbs 8080
# If no arguments: runs in current directory on port 8080

param(
    [string]$ProjectName = "",
    [int]$Port = 8080
)

$SeleniumRoot = "C:\Users\Alaa\Documents\githup\Selenium"
$SSLCert = "C:\ssl\localhost+2.pem"
$SSLKey = "C:\ssl\localhost+2-key.pem"

# Determine target directory
if ($ProjectName -eq "") {
    $TargetDir = Get-Location
    $ProjectName = Split-Path $TargetDir -Leaf
} else {
    $TargetDir = Join-Path $SeleniumRoot $ProjectName
    if (-not (Test-Path $TargetDir)) {
        Write-Host "ERROR: Project '$ProjectName' not found!" -ForegroundColor Red
        Write-Host "`nAvailable projects:" -ForegroundColor Yellow
        Get-ChildItem $SeleniumRoot -Directory | Where-Object { $_.Name -notmatch '^__|logs|scraped_content|deployment_package' } | ForEach-Object { Write-Host "  - $($_.Name)" }
        exit 1
    }
}

# Check if SSL certificates exist
if (-not (Test-Path $SSLCert) -or -not (Test-Path $SSLKey)) {
    Write-Host "ERROR: SSL certificates not found in C:\ssl\" -ForegroundColor Red
    Write-Host "Run this first to create certificates:" -ForegroundColor Yellow
    Write-Host "  C:\ssl\mkcert.exe localhost 127.0.0.1 ::1" -ForegroundColor Cyan
    exit 1
}

# Stop any existing http-server processes
Write-Host "Stopping existing servers..." -ForegroundColor Cyan
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Find the first .html file or use index.html
$HtmlFiles = Get-ChildItem $TargetDir -Filter "*_local.html" -File | Select-Object -First 1
if (-not $HtmlFiles) {
    $HtmlFiles = Get-ChildItem $TargetDir -Filter "index*.html" -File | Select-Object -First 1
}

$StartPage = if ($HtmlFiles) { $HtmlFiles.Name } else { "" }

Write-Host "`nStarting SSL Server" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Project:  " -NoNewline -ForegroundColor Cyan
Write-Host $ProjectName -ForegroundColor White
Write-Host "Directory:" -NoNewline -ForegroundColor Cyan
Write-Host " $TargetDir" -ForegroundColor White
Write-Host "SSL:      " -NoNewline -ForegroundColor Cyan
Write-Host "Enabled (mkcert)" -ForegroundColor Green
Write-Host "Port:     " -NoNewline -ForegroundColor Cyan
Write-Host $Port -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Start server in new minimized window - serve from dist folder if it exists
$ServeDir = if (Test-Path (Join-Path $TargetDir "dist")) { Join-Path $TargetDir "dist" } else { $TargetDir }
$ServerCommand = "cd '$ServeDir'; http-server -S -C '$SSLCert' -K '$SSLKey' -p $Port -c-1"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $ServerCommand -WindowStyle Minimized

Start-Sleep -Seconds 3

# Open browser
$URL = "https://127.0.0.1:$Port/$StartPage"
Write-Host "`nOpening: " -NoNewline -ForegroundColor Cyan
Write-Host $URL -ForegroundColor Yellow

Start-Process chrome -ArgumentList $URL -ErrorAction SilentlyContinue

Write-Host "`nServer running in background window" -ForegroundColor Green
Write-Host "To stop server: Get-Process node | Stop-Process" -ForegroundColor Gray
Write-Host ""
