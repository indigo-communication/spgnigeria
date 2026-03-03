# Test all 15 pages on SSL server
$baseUrl = "https://127.0.0.1:8080"

$pages = @(
    "index.html",
    "about-us.html",
    "projects.html",
    "contact-us.html",
    "construction.html",
    "ready-mix-concrete.html",
    "spg-ready-mix-concrete.html",
    "news.html",
    "product.html",
    "infrastructure.html",
    "real-madrid-football-academy.html",
    "rumuwoji-mile-1-market.html",
    "real-madrid-hostel-classrooms.html",
    "ayinke-house-general-hospital.html",
    "residential-villa.html"
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing All 15 Pages on SSL Server" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$results = @()
foreach ($page in $pages) {
    $url = "$baseUrl/$page"
    try {
        $response = Invoke-WebRequest -Uri $url -SkipCertificateCheck -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            $size = [math]::Round($response.Content.Length / 1KB, 2)
            Write-Host "âœ“ $page - $size KB" -ForegroundColor Green
            $results += [PSCustomObject]@{
                Page = $page
                Status = "OK"
                Size = "$size KB"
            }
        } else {
            Write-Host "âš  $page - Status: $($response.StatusCode)" -ForegroundColor Yellow
            $results += [PSCustomObject]@{
                Page = $page
                Status = $response.StatusCode
                Size = "N/A"
            }
        }
    } catch {
        Write-Host "âœ— $page - Error: $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Page = $page
            Status = "ERROR"
            Size = "N/A"
        }
    }
    Start-Sleep -Milliseconds 200
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$okCount = ($results | Where-Object { $_.Status -eq "OK" }).Count
$totalCount = $results.Count

Write-Host "Pages Tested: $totalCount" -ForegroundColor White
Write-Host "Successful: $okCount" -ForegroundColor Green
Write-Host "Failed: $($totalCount - $okCount)" -ForegroundColor Red

if ($okCount -eq $totalCount) {
    Write-Host "`nâœ“ ALL PAGES LOADED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "`nServer running at: $baseUrl" -ForegroundColor Cyan
    Write-Host "Open in browser to test navigation and images`n" -ForegroundColor Gray
} else {
    Write-Host "`nâš  SOME PAGES FAILED TO LOAD" -ForegroundColor Yellow
}
