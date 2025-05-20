# Start from official PHP + Apache image
FROM php:8.1-apache

RUN a2enmod rewrite

WORKDIR /var/www/html

# Install dependencies and extensions
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev \
    libjpeg-dev libpng-dev libwebp-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd exif pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ✅ Copy full application (including app/helpers.php)
COPY . .

# ✅ Run composer install *after* all necessary files are in place
RUN composer install --no-dev --optimize-autoloader || { echo "Composer install failed"; exit 1; }

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 storage bootstrap/cache || true

EXPOSE 80
CMD ["apache2-foreground"]
