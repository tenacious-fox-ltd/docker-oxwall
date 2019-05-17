FROM php:5-apache

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
      cron \
      libjpeg-dev \
      libfreetype6-dev \
      libpng-dev \
      libssl-dev \
      ssmtp \
      zip \
      mysql-server \
      vim \
      nano \
      proftpd
 && apt-get upgrade -y
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
 && docker-php-ext-install gd mbstring mysql pdo_mysql zip ftp

RUN a2enmod rewrite

ENV OXWALL_VERSION 1.8.4

RUN curl -fsSL -o oxwall.zip \
      "http://www.oxwall.org/dl/oxwall-$OXWALL_VERSION.zip" \
 && mkdir -p /usr/src/oxwall \
 && mv oxwall.zip /usr/src/oxwall/ \
 && cd /usr/src/oxwall \
 && unzip oxwall.zip \
 && rm oxwall.zip

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

RUN /etc/init.d/mysql start \
    && update-rc.d mysql defaults

RUN /etc/init.d/mysql start \
    && mysqladmin -u root password oxwall \
    && mysql -u root -poxwall mysql -e "update user set plugin='mysql_native_password' where User='root';" \
    && mysql -u root -poxwall -e "create database oxwall;"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
