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

return $config;
