# Contact Form Backend Setup

## Files Created

1. **contact_handler.php** - Simple version using PHP's mail() function
2. **contact_handler_smtp.php** - Advanced version with SMTP support (recommended for production)

## How It Works

Both newsletter subscription and contact forms send to: **Sales@spgnigeria.com**

### Forms on Site:
1. **Newsletter Subscription** ("Stay Updated") - Collects email only
2. **Contact Form** - Collects phone, email, and message

## Setup Instructions

### Option 1: Basic Setup (contact_handler.php)

1. Upload `contact_handler.php` to your server
2. Ensure PHP mail() function is enabled on your hosting
3. Test the forms

**Note:** Many shared hosting providers have mail() function enabled by default.

### Option 2: SMTP Setup (Recommended)

For better email delivery, use `contact_handler_smtp.php`:

1. **Install PHPMailer** (if not already installed):
   ```bash
   composer require phpmailer/phpmailer
   ```
   
   Or download manually from: https://github.com/PHPMailer/PHPMailer

2. **Configure SMTP settings** in `contact_handler_smtp.php`:
   ```php
   $smtp_config = [
       'host' => 'smtp.gmail.com',  // Your SMTP server
       'port' => 587,
       'encryption' => 'tls',
       'username' => 'your-email@gmail.com',
       'password' => 'your-app-password',
       'from_email' => 'noreply@spgnigeria.com',
       'from_name' => 'SPG Nigeria Website'
   ];
   ```

3. **For Gmail:**
   - Enable 2-factor authentication
   - Generate an App Password: https://myaccount.google.com/apppasswords
   - Use the app password (not your regular password)

4. **Rename the file:**
   ```bash
   mv contact_handler_smtp.php contact_handler.php
   ```

5. **Uncomment PHPMailer code** in the file (lines marked with comments)

## Testing Locally

The forms won't work on localhost without a PHP server. To test:

1. **Install PHP** (if not already installed)
2. **Start PHP server:**
   ```powershell
   php -S localhost:8080
   ```
3. Open https://127.0.0.1:8080

**Note:** Email sending may not work locally. Deploy to a live server for full testing.

## For Namecheap Deployment

1. Upload all files including `contact_handler.php`
2. Ensure PHP is enabled (Namecheap supports PHP by default)
3. Test forms after deployment
4. Check cPanel → Email Routing to ensure mail delivery

## Security Features

- Email validation and sanitization
- XSS protection with htmlspecialchars()
- CORS headers for AJAX requests
- IP address logging
- Method validation (POST only)

## Troubleshooting

### Emails not sending:
1. Check PHP error logs
2. Verify mail() function is enabled: `php -i | grep sendmail`
3. Check spam folder
4. Use SMTP version instead

### Form not submitting:
1. Check browser console for JavaScript errors
2. Verify contact_handler.php path is correct
3. Ensure PHP is running on the server

### 500 Error:
1. Check file permissions (644 for PHP files)
2. Review server error logs
3. Verify PHP syntax: `php -l contact_handler.php`

## Email Format

**Newsletter Subscription Email:**
```
Subject: Newsletter Subscription - SPG Nigeria
From: noreply@spgnigeria.com
To: Sales@spgnigeria.com

Email: user@example.com
Date: 2026-02-05 10:30:00
IP Address: 192.168.1.1
```

**Contact Form Email:**
```
Subject: Contact Form Submission - SPG Nigeria
From: noreply@spgnigeria.com
To: Sales@spgnigeria.com
Reply-To: user@example.com

Phone: +234 123 456 7890
Email: user@example.com

Message:
[User's message here]

---
Date: 2026-02-05 10:30:00
IP Address: 192.168.1.1
```

## Support

For issues with email delivery, contact your hosting provider's support team.
