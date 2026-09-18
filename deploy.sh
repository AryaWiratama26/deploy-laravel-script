#!/bin/bash

# check php and composer
command -v php >/dev/null 2>&1 || { echo "PHP not installed"; exit 1; }
command -v composer >/dev/null 2>&1 || { echo "Composer not installed"; exit 1; }

# install dependencies without dev packages
composer install --no-dev --optimize-autoloader --no-interaction

# create .env if not exists
if [ ! -f .env ]; then
    cp .env.example .env
fi

# ask for database credentials
read -p "DB_HOST [default: localhost]: " DBHOST
read -p "DB_PORT [default: 3306]: " DBPORT
read -p "DB_DATABASE: " DBNAME
read -p "DB_USERNAME: " DBUSER
read -s -p "DB_PASSWORD: " DBPASS
echo

DBHOST=${DBHOST:-localhost}
DBPORT=${DBPORT:-3306}

# overwrite .env values
sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=mysql/" .env
sed -i "s|^DB_HOST=.*|DB_HOST=${DBHOST}|" .env
sed -i "s/^DB_PORT=.*/DB_PORT=${DBPORT}/" .env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DBNAME}/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DBUSER}/" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DBPASS}|" .env

# generate app key
php artisan key:generate --force

# migrate database
php artisan migrate --force

# set folder permissions
chmod -R 775 storage bootstrap/cache

cp -r public/* .
cp public/.htaccess .

cat > index.php <<'PHP'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/bootstrap/app.php';

$app->handleRequest(Request::capture());
PHP

cat > .htaccess << 'sh'
# Blokir akses langsung ke folder-folder sensitif
RewriteEngine On
RewriteCond %{REQUEST_URI} ^/(app|bootstrap|config|database|lang|resources|routes|storage|tests|vendor)(/|$) [NC]
RewriteRule ^ - [F,L]

# Blokir file-file sensitif
<FilesMatch "^(\.env|composer\.(json|lock)|package(-lock)?\.json|artisan|phpunit\.xml|README\.md|design\.md|vite\.config\.js)$">
    Require all denied
</FilesMatch>

<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Handle X-XSRF-Token Header
    RewriteCond %{HTTP:x-xsrf-token} .
    RewriteRule .* - [E=HTTP_X_XSRF_TOKEN:%{HTTP:X-XSRF-Token}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
sh