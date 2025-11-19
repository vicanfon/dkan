FROM drupal:10-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        zip \
        opcache \
        bcmath \
        mbstring \
        xml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set recommended PHP.ini settings
RUN { \
    echo 'memory_limit=512M'; \
    echo 'max_execution_time=300'; \
    echo 'upload_max_filesize=64M'; \
    echo 'post_max_size=64M'; \
    echo 'max_input_vars=3000'; \
    } > /usr/local/etc/php/conf.d/drupal.ini

# Configure opcache
RUN { \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache.ini

# Set working directory
WORKDIR /var/www/html

# Enable Apache modules
RUN a2enmod rewrite headers expires

# Create entrypoint script to handle permissions
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Create necessary directories and set permissions\n\
mkdir -p /var/www/html/sites/default/files\n\
mkdir -p /var/www/html/sites/default/files/translations\n\
mkdir -p /var/www/html/sites/default/files/php\n\
\n\
# Set ownership\n\
chown -R www-data:www-data /var/www/html/sites/default/files 2>/dev/null || true\n\
chown -R www-data:www-data /var/www/html/vendor 2>/dev/null || true\n\
chown -R www-data:www-data /var/www/html/web 2>/dev/null || true\n\
\n\
# Set permissions\n\
chmod -R 775 /var/www/html/sites/default/files 2>/dev/null || true\n\
\n\
# Make sure settings.php is writable during install, readable after\n\
if [ -f /var/www/html/sites/default/settings.php ]; then\n\
    chmod 644 /var/www/html/sites/default/settings.php\n\
fi\n\
\n\
# Execute the original entrypoint\n\
exec docker-php-entrypoint apache2-foreground\n\
' > /usr/local/bin/custom-entrypoint.sh && chmod +x /usr/local/bin/custom-entrypoint.sh

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
