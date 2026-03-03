# Test all pages on local SSL server
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing All Pages" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$baseUrl = "https://127.0.0.1:8080"

# All 15 pages on the site
$pages = @(
    # Original pages
    "index.html",
    "about-us.html", 
    "projects.html",
    "contact-us.html",
    
    # Division pages
    "construction.html",
    "ready-mix-concrete.html",
    "spg-ready-mix-concrete.html",
    
    # Project detail pages
    "real-madrid-football-academy.html",
    "rumuwoji-mile-1-market.html",
    "real-madrid-hostel-classrooms.html",
    "ayinke-house-general-hospital.html",
    "infrastructure.html",
    "residential-villa.html",
    
    # Other feature pages
    "news.html",
    "product.html"
)

$passCount = 0
$failCount = 0
$results = @()

# Skip certificate validation for local testing
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

foreach ($page in $pages) {
    $url = "$baseUrl/$page"
    Write-Host "Testing: $page" -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $size = [math]::Round($response.Content.Length / 1KB, 2)
            Write-Host " ✓ OK" -ForegroundColor Green -NoNewline
            Write-Host " ($size KB)" -ForegroundColor Gray
            
            # Check if page has images
            $imageCount = ([regex]::Matches($response.Content, '<img')).Count
            if ($imageCount -gt 0) {
                Write-Host "  └─ Images found: $imageCount" -ForegroundColor Gray
            }
            
            $passCount++
            $results += [PSCustomObject]@{
                Page = $page
                Status = "PASS"
                Size = "$size KB"
                Images = $imageCount
            }
        } else {
            Write-Host " ✗ FAIL (Status: $($response.StatusCode))" -ForegroundColor Red
            $failCount++
            $results += [PSCustomObject]@{
                Page = $page
                Status = "FAIL"
                Size = "N/A"
                Images = 0
            }
        }
    }
    catch {
        Write-Host " ✗ FAIL" -ForegroundColor Red
        Write-Host "  └─ Error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
        $results += [PSCustomObject]@{
            Page = $page
            Status = "ERROR"
            Size = "N/A"
            Images = 0
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Pages: $($pages.Count)" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })

if ($failCount -eq 0) {
    Write-Host "`n✓ All pages loaded successfully!" -ForegroundColor Green
} else {
    Write-Host "`n✗ Some pages failed to load" -ForegroundColor Red
    Write-Host "`nFailed Pages:" -ForegroundColor Yellow
    $results | Where-Object { $_.Status -ne "PASS" } | Format-Table -AutoSize
}

Write-Host "`n========================================" -ForegroundColor Cyan
