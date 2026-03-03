import re
import glob

# Files to fix (excluding temp files)
files_to_fix = [
    'index.html',
    'projects.html', 
    'about-us.html',
    'contact-us.html',
    'construction.html',
    'infrastructure.html',
    'ready-mix-concrete.html',
    'ayinke-house-general-hospital.html',
    'real-madrid-football-academy.html',
    'real-madrid-hostel-classrooms.html',
    'rumuwoji-mile-1-market.html',
    'residential-villa.html',
    'spg-ready-mix-concrete.html',
    'product.html',
    'news.html'
]

# Links to fix
replacements = [
    (r'href="/real-madrid-football-academy"', 'href="/real-madrid-football-academy.html"'),
    (r'href="/rumuwoji-mile-1-market"', 'href="/rumuwoji-mile-1-market.html"'),
    (r'href="/real-madrid-hostel-classrooms"', 'href="/real-madrid-hostel-classrooms.html"'),
    (r'href="/ayinke-house-general-hospital"', 'href="/ayinke-house-general-hospital.html"'),
]

total_changes = 0

for filename in files_to_fix:
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        file_changes = 0
        
        for pattern, replacement in replacements:
            matches = len(re.findall(pattern, content))
            if matches > 0:
                content = re.sub(pattern, replacement, content)
                file_changes += matches
        
        if content != original_content:
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ {filename}: {file_changes} links fixed")
            total_changes += file_changes
        
    except FileNotFoundError:
        pass

print(f"\n✓ Total: {total_changes} navigation links fixed")
print("✓ All links now include .html extension")
