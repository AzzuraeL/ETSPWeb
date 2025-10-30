#!/bin/bash

# Set default port if not provided
PORT=${PORT:-8000}

# Start PHP-FPM
service php8.3-fpm start

# Start Nginx
nginx -g 'daemon off;'
