<?php
/**
 * SPG Nigeria - Contact Form Handler with SMTP
 * Requires PHPMailer library for better email delivery
 * 
 * Installation: composer require phpmailer/phpmailer
 * Or download from: https://github.com/PHPMailer/PHPMailer
 */

// Uncomment these lines if using PHPMailer
/*
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php'; // If installed via Composer
// OR
// require 'PHPMailer/src/Exception.php';
// require 'PHPMailer/src/PHPMailer.php';
// require 'PHPMailer/src/SMTP.php';
*/

// Configuration
$recipient_email = "Sales@spgnigeria.com";
$site_name = "SPG Nigeria";

// SMTP Configuration (configure these for your mail server)
$smtp_config = [
    'host' => 'smtp.gmail.com',  // or your SMTP server
    'port' => 587,
    'encryption' => 'tls',       // or 'ssl'
    'username' => 'your-email@gmail.com',
    'password' => 'your-app-password',
    'from_email' => 'noreply@spgnigeria.com',
    'from_name' => 'SPG Nigeria Website'
];

// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$data = $_POST;

if (empty($data['Email'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email is required']);
    exit;
}

$email = filter_var($data['Email'], FILTER_SANITIZE_EMAIL);
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid email address']);
    exit;
}

$is_newsletter = !isset($data['Phone']) && !isset($data['Message']);

// Build email content
if ($is_newsletter) {
    $subject = "Newsletter Subscription - $site_name";
    $body = "<h2>New Newsletter Subscription</h2>";
    $body .= "<p><strong>Email:</strong> $email</p>";
    $body .= "<p><strong>Date:</strong> " . date('Y-m-d H:i:s') . "</p>";
    $body .= "<p><strong>IP Address:</strong> " . $_SERVER['REMOTE_ADDR'] . "</p>";
} else {
    $subject = "Contact Form Submission - $site_name";
    $body = "<h2>New Contact Form Submission</h2>";
    
    if (!empty($data['Phone'])) {
        $phone = htmlspecialchars($data['Phone']);
        $body .= "<p><strong>Phone:</strong> $phone</p>";
    }
    
    $body .= "<p><strong>Email:</strong> $email</p>";
    
    if (!empty($data['Message'])) {
        $msg_content = nl2br(htmlspecialchars($data['Message']));
        $body .= "<p><strong>Message:</strong></p>";
        $body .= "<div style='background:#f5f5f5;padding:15px;border-radius:5px;'>$msg_content</div>";
    }
    
    $body .= "<hr>";
    $body .= "<p><strong>Date:</strong> " . date('Y-m-d H:i:s') . "</p>";
    $body .= "<p><strong>IP Address:</strong> " . $_SERVER['REMOTE_ADDR'] . "</p>";
}

// Send email using PHPMailer (recommended for production)
function sendEmailWithPHPMailer($recipient, $subject, $body, $reply_to, $smtp_config) {
    /*
    // Uncomment this block if using PHPMailer
    try {
        $mail = new PHPMailer(true);
        
        // SMTP configuration
        $mail->isSMTP();
        $mail->Host = $smtp_config['host'];
        $mail->SMTPAuth = true;
        $mail->Username = $smtp_config['username'];
        $mail->Password = $smtp_config['password'];
        $mail->SMTPSecure = $smtp_config['encryption'];
        $mail->Port = $smtp_config['port'];
        
        // Email settings
        $mail->setFrom($smtp_config['from_email'], $smtp_config['from_name']);
        $mail->addAddress($recipient);
        $mail->addReplyTo($reply_to);
        
        $mail->isHTML(true);
        $mail->Subject = $subject;
        $mail->Body = $body;
        $mail->AltBody = strip_tags(str_replace(['<br>', '<br/>', '<br />'], "\n", $body));
        
        $mail->send();
        return true;
    } catch (Exception $e) {
        error_log("PHPMailer Error: {$mail->ErrorInfo}");
        return false;
    }
    */
    
    // Fallback to PHP mail() function for now
    $headers = "From: noreply@spgnigeria.com\r\n";
    $headers .= "Reply-To: $reply_to\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    
    return mail($recipient, $subject, $body, $headers);
}

// Send the email
$mail_sent = sendEmailWithPHPMailer($recipient_email, $subject, $body, $email, $smtp_config);

if ($mail_sent) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => $is_newsletter 
            ? 'Thank you for subscribing to our newsletter!' 
            : 'Thank you for reaching us. Our support team will contact you shortly.'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to send email. Please try again later.'
    ]);
}
?>
