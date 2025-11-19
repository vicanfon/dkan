#!/bin/bash
set -e

# Create necessary directories and set permissions
mkdir -p /var/www/html/sites/default/files
mkdir -p /var/www/html/sites/default/files/translations
mkdir -p /var/www/html/sites/default/files/php

# Set ownership
chown -R www-data:www-data /var/www/html/sites/default/files
chown -R www-data:www-data /var/www/html/vendor 2>/dev/null || true
chown -R www-data:www-data /var/www/html/web 2>/dev/null || true

# Set permissions
chmod -R 775 /var/www/html/sites/default/files

# Make sure settings.php is writable during install, readable after
if [ -f /var/www/html/sites/default/settings.php ]; then
    chmod 644 /var/www/html/sites/default/settings.php
fi

# Execute the original entrypoint
exec docker-php-entrypoint apache2-foreground
