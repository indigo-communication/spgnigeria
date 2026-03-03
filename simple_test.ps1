$pages = @("index.html", "about-us.html", "projects.html", "contact-us.html", "construction.html", "ready-mix-concrete.html", "spg-ready-mix-concrete.html", "news.html", "product.html", "infrastructure.html", "real-madrid-football-academy.html", "rumuwoji-mile-1-market.html", "real-madrid-hostel-classrooms.html", "ayinke-house-general-hospital.html", "residential-villa.html")

Write-Host "`nTesting 15 pages...`n" -ForegroundColor Cyan

$ok = 0
$failed = 0

foreach ($page in $pages) {
    try {
        $r = Invoke-WebRequest -Uri "https://127.0.0.1:8080/$page" -SkipCertificateCheck -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) {
            Write-Host "✓ $page" -ForegroundColor Green
            $ok++
        }
    }
    catch {
        Write-Host "✗ $page" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`nResults: $ok OK, $failed Failed" -ForegroundColor Cyan
