# Start from official PHP + Apache image
FROM php:8.1-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev && \
    docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files first
COPY composer.json composer.lock ./

# Install PHP dependencies (this will fail if composer.json is broken or deps are missing)
RUN composer install --no-dev --optimize-autoloader || { echo "Composer install failed"; exit 1; }

# Copy rest of app
COPY . .

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Laravel storage & cache must be writable
RUN chmod -R 775 storage bootstrap/cache || true

# Expose Apache
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
