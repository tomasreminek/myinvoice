<?php
$config = require __DIR__ . '/cfg.sample.php';

// Nastavení databáze pro Docker (bereme z Environment Variables v Coolify)
$config['db']['host'] = 'db';
$config['db']['user'] = getenv('DB_USER') ?: 'myinvoice';
$config['db']['pass'] = getenv('DB_PASSWORD') ?: 'changeme';
$config['db']['name'] = getenv('DB_NAME') ?: 'myinvoice';

// Bezpečnostní klíče z Coolify
if (getenv('APP_PEPPER')) {
    $config['app']['pepper'] = getenv('APP_PEPPER');
}
if (getenv('APP_SECRET')) {
    $config['app']['secret_encryption_key'] = getenv('APP_SECRET');
}
if (getenv('APP_URL')) {
    $config['app']['url'] = getenv('APP_URL');
}

// Cloudflare Turnstile CAPTCHA
if (getenv('CAPTCHA_SITE_KEY') && getenv('CAPTCHA_SECRET_KEY')) {
    $config['captcha']['provider']   = 'turnstile';
    $config['captcha']['site_key']   = getenv('CAPTCHA_SITE_KEY');
    $config['captcha']['secret_key'] = getenv('CAPTCHA_SECRET_KEY');
} else {
    // Bez platných klíčů CAPTCHA vypnout — jinak Turnstile s 'CHANGE-ME' blokuje login
    $config['captcha']['provider'] = 'none';
}

// Nastavení e-mailů (SMTP) z Coolify
if (getenv('SMTP_HOST')) {
    $config['smtp']['host'] = getenv('SMTP_HOST');
    $config['smtp']['port'] = getenv('SMTP_PORT') ?: 587;
    $config['smtp']['user'] = getenv('SMTP_USER') ?: '';
    $config['smtp']['pass'] = getenv('SMTP_PASS') ?: '';
    $config['smtp']['from_email'] = getenv('SMTP_FROM_EMAIL') ?: 'noreply@' . parse_url($config['app']['url'], PHP_URL_HOST);
    $config['smtp']['from_name'] = getenv('SMTP_FROM_NAME') ?: 'MyInvoice';
    $config['smtp']['encryption'] = getenv('SMTP_ENCRYPTION') ?: 'tls';
}

return $config;
