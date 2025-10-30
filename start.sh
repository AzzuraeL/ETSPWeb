#!/bin/bash

# Start PHP-FPM
service php8.3-fpm start

# Start Nginx
nginx -g 'daemon off;'
