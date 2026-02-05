# Spgnigeria - Subproject Workflow

**Domain:** www.spgnigeria.com  
**Contact:** info@spgnigeria.com  
**Status:** ⏳ PENDING  
**Workspace:** `c:\Users\Alaa\Documents\githup\Selenium\spgnigeria\`

---

## Project Context

This is **subproject #5** of an 11-website migration project. Each domain gets its own isolated folder within the Selenium workspace.

**Reference Project:** `../limen groupe/` (Completed Feb 1, 2026)  
**Parent Guide:** `../PROJECT_WORKFLOW_GUIDE.md`

---

## Workflow Stages (From Parent Guide)

Follow the 11-stage workflow documented in PROJECT_WORKFLOW_GUIDE.md:

1. ⏳ Project Initialization
2. ⏳ Source Code Import
3. ⏳ Initial Local Testing
4. ⏳ Asset Localization - Images
5. ⏳ Asset Localization - CSS/JS
6. ⏳ Path Replacement
7. ⏳ JavaScript Localization
8. ⏳ Special Fixes
9. ⏳ Backend Implementation (Create contact_handler.php for email)
10. ⏳ Final Testing (Cross-browser, forms, responsive)
11. ⏳ Deployment Package (Create .htaccess, ZIP for Namecheap)

**Update this README as you complete each stage.**

---

## Critical Fixes Applied

### 🔥 CRITICAL: Image Quality - Always Use High Resolution

**⚠️ NEVER DOWNLOAD LOW-RESOLUTION IMAGES ⚠️**

**Rule:** Always download the highest quality/original images from the live site. Check image URLs for size parameters (s1600, s800, s400, w=800, h=600, etc.) and use the highest available size or remove size parameters entirely. Compare downloaded file sizes with live site images to ensure quality matches.

**Example:**
```powershell
# ❌ BAD - Downloads low-res version
Invoke-WebRequest "https://lh3.googleusercontent.com/image.jpg=s400"

# ✅ GOOD - Downloads high-res version
Invoke-WebRequest "https://lh3.googleusercontent.com/image.jpg=s1600"

# ✅ BETTER - Downloads original
Invoke-WebRequest "https://lh3.googleusercontent.com/image.jpg"
```

*Document all fixes here as you discover and resolve issues. Use yellowecoenergy and limen groupe READMEs as templates.*

### Common Issues to Check

1. **🔥 INDIGO MULTI-PAGE SITES** - If pages show mobile view: Extract vbid per page and download separate CSS files. See mirsat README for complete fix.
2. **Path Issues** - Check for `/dist/` prefixes or absolute paths
3. **HTTPS Redirects** - Comment out for localhost testing
4. **CDN URLs** - Identify and localize all external resources
5. **CSS url() References** - Check CSS files for image paths
6. **JavaScript CDNs** - Look for hardcoded URLs in JS files
7. **Navigation Links** - Convert absolute paths to relative
8. **Tracking Scripts** - Disable Analytics/Facebook/YouTube for local testing

---

### Local Testing Methods

**🔐 SSL Server (RECOMMENDED - No HTTPS redirect issues!):**

**Option 1: Quick Start**
```powershell
.\start.ps1
```

**Option 2: Universal Launcher**
```powershell
.\start_ssl_server.ps1 spgnigeria 8080
```

**Option 3: Manual SSL Server**
```powershell
http-server -S -C "C:\ssl\localhost+2.pem" -K "C:\ssl\localhost+2-key.pem" -p 8080
# Open: https://127.0.0.1:8080
```

**🛠️ SSL Setup (Already Done!)** - Certificates in C:\ssl\ valid until May 3, 2028

**📋 Stop Server:** `Get-Process node | Stop-Process`

**Alternative Methods:**
1. **file:// Protocol:** `start chrome "file:///c:/Users/Alaa/Documents/githup/Selenium/spgnigeria/index.html"`
2. **http-server:** `http-server -p 8080`

---

### Complete Project Realization Checklist

⏳ **Stage 1-3: Initial Setup**
- [ ] Create folder structure
- [ ] Download HTML source
- [ ] Set up local testing environment
- [ ] Identify external dependencies (DevTools → Network tab)

⏳ **Stage 4: Image Localization**
- [ ] Extract image URLs with regex
- [ ] Download to images/ folder
- [ ] Replace URLs in HTML
- [ ] Check CSS files for url() image references

⏳ **Stage 5-6: CSS/JS Localization**
- [ ] Identify external CSS/JS files
- [ ] Download to assets/css/ and assets/js/
- [ ] Update script/link tags in HTML
- [ ] Check for page-specific CSS (vbid system)

⏳ **Stage 7: JavaScript Fixes**
- [ ] Check for hardcoded CDN URLs in JS files
- [ ] Disable HTTPS redirect scripts
- [ ] Disable tracking scripts (Analytics, Facebook)
- [ ] Modify image loading if needed

⏳ **Stage 8: Special Fixes**
- [ ] Fix navigation links (absolute → relative)
- [ ] Remove external server references
- [ ] Test all pages and features

⏳ **Stage 9: Backend Implementation**
- [ ] Create contact_handler.php for email
- [ ] Configure SMTP or PHP mail()
- [ ] Add form validation
- [ ] Test email delivery

⏳ **Stage 10: Final Testing**
- [ ] Test in Chrome, Firefox, Safari, Edge
- [ ] Validate responsive design
- [ ] Test all navigation links
- [ ] Verify form submissions
- [ ] Check image loading

⏳ **Stage 11: Deployment Package**
- [ ] Create .htaccess file
- [ ] Re-enable HTTPS redirect and tracking
- [ ] Create spgnigeria_deployment.zip
- [ ] Push to GitHub with ZIP included
- [ ] Test on Namecheap after upload

---

### Useful PowerShell Scripts

**Extract Image URLs:**
```powershell
$content = Get-Content "index.html" -Raw
$urls = [regex]::Matches($content, 'https://[^\"\\s]+\\.(jpg|jpeg|png|gif|svg|webp)') | 
    ForEach-Object { $_.Value } | Select-Object -Unique
$urls | Out-File "image_urls.txt"
Write-Host "Found $($urls.Count) unique images"
```

**Download Images:**
```powershell
$urls = Get-Content "image_urls.txt"
New-Item -ItemType Directory -Force -Path "images" | Out-Null
foreach ($url in $urls) {
    $filename = Split-Path $url -Leaf
    Invoke-WebRequest -Uri $url -OutFile "images/$filename"
    Write-Host "Downloaded: $filename"
}
```

**Replace URLs:**
```powershell
$content = Get-Content "index.html" -Raw
$content = $content -replace 'https://cdn\\.example\\.com/', ''
Set-Content "index.html" $content -NoNewline
```

**Disable HTTPS Redirect:**
```powershell
# Problem: Pages redirect to HTTPS causing SSL errors on localhost
# Solution: Comment out the HTTPS redirect script

$files = @('index.html', 'about-us.html', 'services.html', 'contact.html')
foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # Find and comment out HTTPS redirect script
        $pattern = '(<script[^>]*>[\s\S]*?if\s*\(\s*window\.location\.protocol\s*!=\s*[''"]https:[''"][\s\S]*?</script>)'
        $replacement = "<!-- DISABLED FOR LOCAL TESTING:`n`$1`n-->"
        $content = $content -replace $pattern, $replacement
        
        # Save with UTF-8 encoding (preserves Arabic/international text)
        $content | Set-Content $file -Encoding UTF8 -NoNewline
        Write-Host "? Fixed HTTPS redirect in $file"
    }
}

Write-Host "`n? HTTPS redirect disabled!"
Write-Host "?? For deployment: Re-enable in production version"
```

**Fix Navigation Links (Absolute to Relative):**
```powershell
# Convert absolute paths to relative for local testing
$files = @('index.html', 'about-us.html', 'services.html', 'contact.html')
foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # Fix common navigation patterns
        $content = $content -replace 'href="/"([^"])', 'href="index.html"'
        $content = $content -replace 'href="/about-us"', 'href="about-us.html"'
        $content = $content -replace 'href="/services"', 'href="services.html"'
        $content = $content -replace 'href="/contact"', 'href="contact.html"'
        
        $content | Set-Content $file -Encoding UTF8 -NoNewline
        Write-Host "? Fixed navigation links in $file"
    }
}
```

---

### Important Notes

- Study yellowecoenergy and limen groupe READMEs for detailed examples
- Always test locally before creating deployment package
- Document every fix in this README for future reference
- Never use file:// for sites with JavaScript navigation issues
- **GitHub:** Push repository with deployment ZIP included

---

## For New AI Conversations

**Start Here:**
1. Read `../PROJECT_WORKFLOW_GUIDE.md` (complete workflow)
2. Study `../limen groupe/README.md` (reference implementation)
3. Study `../yellowecoenergy/README.md` (8 critical methods)
4. Check `../publicmatterslebanon/README.md` (common issues)
5. Begin Stage 1 of workflow

**DO NOT:**
- Skip workflow stages
- Copy files from other projects
- Assume localhost setup without reading the guide

**Expected Timeline:** Single day (based on limen groupe)

---

**Created:** February 1, 2026  
**Status:** Awaiting initialization
