FROM php:7.3-apache
MAINTAINER yun young jin <yupmin@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
# for composer
    apt-get -y install zip git && \
    apt-get -y install \
# for intl
    libicu-dev \
# for zip
    libzip-dev && \
    docker-php-ext-install opcache intl bcmath zip pdo_mysql
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 12M/" /usr/local/etc/php/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /usr/local/etc/php/php.ini
# for apache
RUN a2dissite 000-default.conf && a2dissite default-ssl.conf && \
    a2enmod rewrite

COPY . /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER 1
RUN cp .env.example .env && \
    curl -sS https://getcomposer.org/installer | php -- && \
# for more speed
    php composer.phar --no-ansi config -g repos.packagist composer https://packagist.jp && \
    php composer.phar --no-ansi global require hirak/prestissimo && \
# composer install
    php composer.phar --no-ansi install --no-dev --no-scripts && \
# change directory permission
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache/ && \
    cp docker/default.conf /etc/apache2/sites-available && a2ensite default.conf
