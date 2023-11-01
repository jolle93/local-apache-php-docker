FROM php:8.2-apache
RUN apt-get clean && apt-get update && apt-get install -y libzip-dev && docker-php-ext-install zip
RUN apt-get install -y \
            libfreetype6-dev \
            libjpeg62-turbo-dev \
            libpng-dev \
            libwebp-dev \
    		zlib1g-dev \
    		libxml2-dev \
    		ssmtp \
    	    mailutils


RUN set -e; \
    docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype; \
    docker-php-ext-install -j$(nproc) gd

RUN echo "hostname=localhost.localdomain" > /etc/ssmtp/ssmtp.conf
RUN echo "root=kontakt@julian-paul.de" >> /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=rheinwerk24" >> /etc/ssmtp/ssmtp.conf

RUN apt-get install -y sendmail
RUN echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini
RUN sed -i '/#!\/bin\/sh/aservice sendmail restart' /usr/local/bin/docker-php-entrypoint
RUN sed -i '/#!\/bin\/sh/aecho "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts' /usr/local/bin/docker-php-entrypoint

RUN rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install soap
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable mysqli && a2enmod rewrite

