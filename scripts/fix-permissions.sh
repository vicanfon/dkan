#!/bin/bash
# Script to fix Drupal file permissions in Docker container

echo "Fixing Drupal file permissions..."

# Create necessary directories
mkdir -p /var/www/html/sites/default/files
mkdir -p /var/www/html/sites/default/files/translations
mkdir -p /var/www/html/sites/default/files/php
mkdir -p /var/www/html/sites/default/private

# Set ownership to www-data
chown -R www-data:www-data /var/www/html/sites/default/files
chown -R www-data:www-data /var/www/html/vendor 2>/dev/null || true
chown -R www-data:www-data /var/www/html/web 2>/dev/null || true

# Set permissions
chmod -R 775 /var/www/html/sites/default/files

# Fix settings.php permissions if it exists
if [ -f /var/www/html/sites/default/settings.php ]; then
    chmod 644 /var/www/html/sites/default/settings.php
    chown www-data:www-data /var/www/html/sites/default/settings.php
fi

# Fix settings.php permissions if it exists in web directory
if [ -f /var/www/html/web/sites/default/settings.php ]; then
    chmod 644 /var/www/html/web/sites/default/settings.php
    chown www-data:www-data /var/www/html/web/sites/default/settings.php
fi

echo "Permissions fixed successfully!"
echo ""
echo "The following directories are now writable:"
echo "  - /var/www/html/sites/default/files"
echo ""
echo "You can now continue with the Drupal installation."
