#!/bin/bash

# We need to install dependencies only for Docker
[[ ! -e /.dockerenv ]] && exit 0
set -xe

apt-get update -yq
apt-get install -yq --no-install-recommends \
    openssl openssh-client git curl unzip wget gnupg \
    zlib1g-dev libicu-dev g++ libcurl4-gnutls-dev libpng-dev libmcrypt-dev libxml2-dev iproute2

# Necessary for xmlreader extension
export CFLAGS="-I/usr/src/php"

cp /build/php.ini /usr/local/etc/php/php.ini

docker-php-ext-install pdo
docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
docker-php-ext-install pdo_mysql
docker-php-ext-configure intl && \
docker-php-ext-install intl
docker-php-ext-install curl json gd mcrypt opcache tokenizer dom xml zip ctype fileinfo mbstring soap exif xmlwriter xmlreader simplexml bcmath pcntl

# Install APCu extension
wget -O /tmp/apcu.tar.gz https://pecl.php.net/get/apcu-5.1.11.tgz
mkdir -p /usr/src/php/ext/apcu && tar xf /tmp/apcu.tar.gz -C /usr/src/php/ext/apcu --strip-components=1
docker-php-ext-configure apcu && docker-php-ext-install apcu
rm -rd /usr/src/php/ext/apcu && rm /tmp/apcu.tar.gz

# Install APCu-BC extension
wget -O /tmp/apcu_bc.tar.gz https://pecl.php.net/get/apcu_bc-1.0.4.tgz
mkdir -p /usr/src/php/ext/apcu-bc && tar xf /tmp/apcu_bc.tar.gz -C /usr/src/php/ext/apcu-bc --strip-components=1
docker-php-ext-configure apcu-bc && docker-php-ext-install apcu-bc
rm -rd /usr/src/php/ext/apcu-bc && rm /tmp/apcu_bc.tar.gz

#Load APCU.ini before APC.ini
rm /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini
echo extension=apcu.so > /usr/local/etc/php/conf.d/20-php-ext-apcu.ini

rm /usr/local/etc/php/conf.d/docker-php-ext-apc.ini
echo extension=apc.so > /usr/local/etc/php/conf.d/21-php-ext-apc.ini

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

composer global require "andres-montanez/magallanes"

echo "export PATH=$PATH:/root/.composer/vendor/bin" >> ~/.bashrc

# install nodejs
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install build-essential nodejs -yq

# install global npm packages
npm install -g bower gulp gulp-cli uglify-js uglifycss elasticdump

# install yarn
curl -o- -L https://yarnpkg.com/install.sh | bash

source ~/.bashrc

node -v
npm -v
yarn -v

echo $PATH
