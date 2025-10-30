# Stage 1: Composer dependencies
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist

# Stage 2: PHP runtime
FROM php:8.3-cli
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y unzip libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Copy source + vendor
COPY --from=vendor /app/vendor /app/vendor
COPY . .

# Allow Railway to map the port dynamically
EXPOSE 8000

# Run Laravel server with environment variable expansion
ENTRYPOINT [ "sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8000}" ]
