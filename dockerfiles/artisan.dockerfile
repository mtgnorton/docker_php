FROM php:7.2-fpm

ARG UID
ARG GID

ARG INSTALL_BEAST=false

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.

###########################################################################
# Beast EXTENSION
###########################################################################

RUN if [ ${INSTALL_BEAST} = true ]; then \
    # Install the beast extension
    apt-get update && apt-get install -y sudo wget unzip gcc make git \
    && mkdir -p /tmp/beast-php \
    && cd /tmp/beast-php \
    && wget https://github.com/liexusong/php-beast/archive/master.zip \
    && unzip master.zip \
    && cd php-beast-master \
    && phpize \
    && ./configure \
    && sudo make && make install \
    && rm -rf /tmp/beast-php \
    && docker-php-ext-enable beast \
;fi

RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install zip


RUN docker-php-ext-install pdo pdo_mysql bcmath

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis


CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
