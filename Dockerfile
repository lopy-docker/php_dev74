# build:
#

# This dockerfile uses the ubuntu image
# VERSION 2 - EDITION 1
# Author: docker_user
# Command format: Instruction [arguments / command ] ..

# Base image to use, this nust be set as the first line
FROM php:7.4-fpm-buster

# Maintainer: docker_user <docker_user at email.com> (@docker_user)
MAINTAINER zengyu 284141050@qq.com

RUN echo "change apt source" \
    && echo "deb http://ftp.debian.org/debian buster main contrib non-free" >/etc/apt/sources.list \
    && echo "deb http://ftp.debian.org/debian buster-updates main contrib non-free" >>/etc/apt/sources.list \
    && echo "deb http://security.debian.org buster/updates main contrib non-free" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y sudo \
    unzip \
    unrar \
    libzip-dev \
    proxychains \
    zlib1g-dev \
    procps inetutils-ping \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libssl-dev \
    && sed -i 's/socks4/#socks4/g' /etc/proxychains.conf \
    && sed -i '$a\socks5 	172.17.0.1 1080' /etc/proxychains.conf \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-webp=/usr/include --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install zip mysqli\
    && pecl install xdebug igbinary zstd\
    && docker-php-ext-enable xdebug igbinary zstd\
    && printf "yes\nyes\n\n" | pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /tmp/pear

# && pecl install inotify \
# && docker-php-ext-enable inotify \
# && printf "\nyes\n\n" | pecl install swoole \
# && docker-php-ext-enable swoole\


RUN useradd debian  -s /bin/bash -m -k /etc/skel \
    && echo "debian  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && usermod -G debian www-data

# composer
RUN echo 'install composer' \
    && cd /usr/local/bin/ \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar composer \
    && sudo -u debian composer global require 'codeception/codeception'
#    && sudo -u debian ./composer.phar global require 'composer/composer:dev-master' \


# update env
RUN echo "update env" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/root/.bashrc" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/home/debian/.bashrc" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/root/.profile" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/home/debian/.profile" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/etc/profile" 


# support zh-cn
ENV LANG=C.UTF-8 \
    TZ=Asia/Chongqing

# Commands when creating a new container
# CMD ["php","-a"]