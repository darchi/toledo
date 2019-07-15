FROM php:7.1.28-fpm-alpine

ADD lib/pecl-memcache-NON_BLOCKING_IO_php7/ /tmp/pecl-memcache-NON_BLOCKING_IO_php7

RUN apk add --no-cache --update \
 curl \
 wget \
 git \
 zlib \
 libssh2-dev \
 libxml2-dev \
 libmcrypt-dev \
 freetype-dev \
 libpng-dev \
 libjpeg-turbo-dev \
 libmemcached \
 php-gd \
 openssh \
 $PHPIZE_DEPS \
 && docker-php-ext-install -j$(nproc) opcache soap xmlrpc dom xml iconv mcrypt mbstring mysqli pdo pdo_mysql zip \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd \
 && pecl install ssh2-1.1.2 \
 && docker-php-ext-enable ssh2 \
 && cd /tmp/pecl-memcache-NON_BLOCKING_IO_php7/ \
 && phpize \
 && ls -lh \
 && ./configure --enable-memcache \
 && make \
 && mv modules/memcache.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303/memcache.so \
 && echo 'extension=memcache.so' >> /usr/local/etc/php/conf.d/docker-php-ext-memcache.ini \
 && pecl install xdebug-2.7.2 \
 && docker-php-ext-enable xdebug \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
ADD php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www

EXPOSE 9000
