import re
import hashlib
import urllib.request
import os
from pathlib import Path

# Files to process
html_files = [
    'news.html',
    'product.html',
    'spg-ready-mix-concrete.html',
    'residential-villa.html'
]

# Extract all Google Cloud Storage URLs
def extract_image_urls(html_content):
    """Extract all Google Cloud Storage image URLs from HTML content"""
    # Match URLs with or without size parameters
    pattern = r'https://lh3\.googleusercontent\.com/[A-Za-z0-9_\-]+(?:=s\d+)?'
    urls = re.findall(pattern, html_content)
    # Remove size parameters and get unique URLs
    unique_urls = set()
    for url in urls:
        base_url = url.split('=s')[0]  # Remove size parameter
        unique_urls.add(base_url)
    return sorted(list(unique_urls))

def get_md5_hash(url):
    """Get MD5 hash of URL for generating filename"""
    return hashlib.md5(url.encode()).hexdigest()

def download_image(url, output_path):
    """Download an image from URL to output_path"""
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            with open(output_path, 'wb') as out_file:
                out_file.write(response.read())
        return True
    except Exception as e:
        print(f"Error downloading {url}: {e}")
        return False

def process_files():
    """Main processing function"""
    all_urls = set()
    
    # Extract URLs from all HTML files
    print("Extracting image URLs from HTML files...")
    for filename in html_files:
        if os.path.exists(filename):
            with open(filename, 'r', encoding='utf-8') as f:
                content = f.read()
                urls = extract_image_urls(content)
                all_urls.update(urls)
                print(f"  {filename}: {len(urls)} unique URLs found")
    
    print(f"\nTotal unique URLs across all files: {len(all_urls)}")
    
    # Save URLs to file
    with open('additional_images.txt', 'w', encoding='utf-8') as f:
        for url in sorted(all_urls):
            f.write(url + '\n')
    print(f"Saved URLs to additional_images.txt")
    
    # Check existing images
    images_dir = Path('images')
    existing_images = set(f.name for f in images_dir.glob('img_*.jpg'))
    
    # Download new images
    print("\nDownloading images...")
    downloaded = 0
    skipped = 0
    failed = 0
    
    url_to_filename = {}
    
    for url in sorted(all_urls):
        md5_hash = get_md5_hash(url)
        filename = f"img_{md5_hash}.jpg"
        filepath = images_dir / filename
        url_to_filename[url] = filename
        
        if filename in existing_images:
            print(f"  Skipped (exists): {filename}")
            skipped += 1
        else:
            print(f"  Downloading: {filename}")
            if download_image(url, filepath):
                downloaded += 1
            else:
                failed += 1
    
    print(f"\nDownload Summary:")
    print(f"  Downloaded: {downloaded}")
    print(f"  Skipped (existed): {skipped}")
    print(f"  Failed: {failed}")
    
    # Update HTML files
    print("\nUpdating HTML files...")
    for filename in html_files:
        if not os.path.exists(filename):
            continue
            
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements = 0
        
        # Replace Google Cloud Storage URLs with local paths
        for url in all_urls:
            local_filename = url_to_filename[url]
            # Replace URL with size parameters first (more specific)
            pattern_with_size = url + r'=s\d+'
            matches = re.findall(re.escape(url) + r'=s\d+', content)
            for match in matches:
                content = content.replace(match, f'images/{local_filename}')
                replacements += 1
            
            # Then replace URL without size parameters
            content = content.replace(url, f'images/{local_filename}')
            replacements += original_content.count(url) - len(matches)
        
        # Remove any remaining size parameters from local image paths
        content = re.sub(r'images/(img_[a-f0-9]+\.jpg)=s\d+', r'images/\1', content)
        replacements += len(re.findall(r'images/(img_[a-f0-9]+\.jpg)=s\d+', original_content))
        
        # Fix navigation links
        nav_replacements = {
            'href="/construction"': 'href="construction.html"',
            'href="/projects"': 'href="projects.html"',
            'href="/about-us"': 'href="about-us.html"',
            'href="/contact-us"': 'href="contact-us.html"',
            'href="/infrastructure"': 'href="infrastructure.html"',
            'href="/news"': 'href="news.html"',
            'href="/product"': 'href="product.html"',
        }
        
        for old, new in nav_replacements.items():
            new_content = content.replace(old, new)
            if new_content != content:
                replacements += content.count(old)
                content = new_content
        
        # Fix JavaScript URLs
        js_replacements = {
            '//www.indigo-cy.com/js/lib/jquery-2.x-git.min.js': 'assets/js/lib/jquery-2.x-git.min.js',
            '//www.indigo-cy.com/js/xprs_helper.js': 'assets/js/xprs_helper.js',
            '//www.indigo-cy.com/js/lib/touchswipe/jquery.mobile.custom.min.js': 'assets/js/lib/touchswipe/jquery.mobile.custom.min.js',
            '//www.indigo-cy.com/js/lightbox.js': 'assets/js/lightbox.js',
            '//www.indigo-cy.com/js/spimeengine.js': 'assets/js/spimeengine.js',
        }
        
        for old, new in js_replacements.items():
            # Handle both with and without query strings
            pattern = re.escape(old) + r'(?:\?[^"]*)?'
            new_content = re.sub(pattern, new, content)
            if new_content != content:
                replacements += len(re.findall(pattern, content))
                content = new_content
        
        # Write updated content
        if content != original_content:
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  {filename}: {replacements} replacements made")
        else:
            print(f"  {filename}: No changes needed")
    
    print("\nLocalization complete!")
    print(f"Total URLs processed: {len(all_urls)}")
    print(f"New images downloaded: {downloaded}")

if __name__ == '__main__':
    process_files()
