FROM php:7.3-fpm-alpine
MAINTAINER yun young jin <yupmin@gmail.com>

RUN apk update && \
# for composer
    apk add zip git && \
    apk add --no-cache \
# for intl
    icu-dev \
# for zip
    zlib-dev libzip-dev && \
    docker-php-ext-install opcache intl bcmath zip pdo_mysql
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s/display_errors = Off/display_errors = On/" /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 12M/" /usr/local/etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /usr/local/etc/php/php.ini && \
#    sed -i "s/;error_log =.*/error_log = \/proc\/self\/fd\/2/" /usr/local/etc/php-fpm.conf && \
    sed -i "s/listen = .*/listen = 9000/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_children = .*/pm.max_children = 200/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.start_servers = .*/pm.start_servers = 56/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 32/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 96/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/^;clear_env = no$/clear_env = no/" /usr/local/etc/php-fpm.d/www.conf

COPY . /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER 1
RUN cp .env.example .env && \
    curl -sS https://getcomposer.org/installer | php -- && \
# for more speed
    php composer.phar config -g repos.packagist composer https://packagist.jp && \
    php composer.phar global require hirak/prestissimo && \
# composer install
    php composer.phar install --no-dev --no-scripts && \
    php composer.phar dumpautoload --optimize && \
# change directory permission
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache/

