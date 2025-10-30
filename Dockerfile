FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpq-dev \
    libmariadb-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    zip \
    && docker-php-ext-enable pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Make start script executable
RUN chmod +x start.sh

# Install dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader
RUN npm install
RUN npm run build

# Create cache directories and permissions
RUN mkdir -p storage/framework/{sessions,views,cache,testing} storage/logs \
    && chmod -R 777 storage bootstrap/cache

# Run Laravel caching commands
RUN php artisan config:cache \
    && php artisan route:cache

# Install Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start Nginx and PHP-FPM
CMD ["/bin/bash", "-c", "service php8.3-fpm start && nginx -g 'daemon off;'"]
