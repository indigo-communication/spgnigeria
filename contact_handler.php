<?php
/**
 * SPG Nigeria - Contact Form Handler
 * Handles both newsletter subscription and contact form submissions
 */

// Configuration
$recipient_email = "Sales@spgnigeria.com";
$site_name = "SPG Nigeria";

// CORS headers for AJAX requests
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Get POST data
$data = $_POST;

// Validate required fields
if (empty($data['Email'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email is required']);
    exit;
}

// Sanitize email
$email = filter_var($data['Email'], FILTER_SANITIZE_EMAIL);
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid email address']);
    exit;
}

// Determine form type
$is_newsletter = !isset($data['Phone']) && !isset($data['Message']);

// Build email content
if ($is_newsletter) {
    // Newsletter subscription
    $subject = "Newsletter Subscription - $site_name";
    $message = "New newsletter subscription request:\n\n";
    $message .= "Email: $email\n";
    $message .= "Date: " . date('Y-m-d H:i:s') . "\n";
    $message .= "IP Address: " . $_SERVER['REMOTE_ADDR'] . "\n";
} else {
    // Contact form
    $subject = "Contact Form Submission - $site_name";
    $message = "New contact form submission:\n\n";
    
    if (!empty($data['Phone'])) {
        $phone = htmlspecialchars($data['Phone']);
        $message .= "Phone: $phone\n";
    }
    
    $message .= "Email: $email\n";
    
    if (!empty($data['Message'])) {
        $msg_content = htmlspecialchars($data['Message']);
        $message .= "\nMessage:\n$msg_content\n";
    }
    
    $message .= "\n---\n";
    $message .= "Date: " . date('Y-m-d H:i:s') . "\n";
    $message .= "IP Address: " . $_SERVER['REMOTE_ADDR'] . "\n";
}

// Email headers
$headers = "From: noreply@spgnigeria.com\r\n";
$headers .= "Reply-To: $email\r\n";
$headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";
$headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

// Send email
$mail_sent = mail($recipient_email, $subject, $message, $headers);

if ($mail_sent) {
    // Success response
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => $is_newsletter 
            ? 'Thank you for subscribing to our newsletter!' 
            : 'Thank you for reaching us. Our support team will contact you shortly.'
    ]);
} else {
    // Error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to send email. Please try again later.'
    ]);
}
?>
