# Use the official PHP image with the necessary extensions and Apache
FROM php:8.2-apache

ARG RDS_INSTANCE

ENV RDS_INSTANCE_ENV=${RDS_INSTANCE}

# Install system dependencies and PHP extensions required by Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./apache.conf /etc/apache2/sites-available/000-default.conf

# Enable Apache rewrite module
RUN a2enmod rewrite

#sample

COPY ./docker-entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the application code into the container
COPY . /var/www/html

## Install dependencies
RUN composer install

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["${RDS_INSTANCE}"]