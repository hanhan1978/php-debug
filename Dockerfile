FROM debian:buster as builder

ENV PHP_VERSION  8.0.0

RUN apt update \
    && apt install -y \
    curl \
    build-essential \
    libxml2-dev \
    pkg-config \
    libsqlite3-dev \
    libssl-dev \
    zlib1g-dev \
    libcurl4-nss-dev \
    libonig-dev \
    libffi-dev \
    libedit-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fSL -o php.tar.gz "https://www.php.net/distributions/php-$PHP_VERSION.tar.gz" \
    && mkdir /usr/local/php-src \
    && tar xzf php.tar.gz -C /usr/local/php-src --strip-components 1 \
    && rm php.tar.gz

WORKDIR /usr/local/php-src

RUN ./configure  \
    CFLAGS='-g -O0' \
    --with-config-file-path=/etc/php \
    --with-config-file-scan-dir=/etc/php/conf.d \
    --disable-cgi \
    --enable-ftp \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-curl \
    --with-libedit \
    --with-openssl \
    --with-zlib \
    --enable-debug \
    --enable-opcache \
    --with-ffi \
    --enable-fpm \
    && make -j4 \
    && make install

FROM debian:buster-slim

COPY --from=builder /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=builder /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=builder /lib64 /lib64
COPY --from=builder /usr/local/php-src /usr/local/php-src 

COPY --from=builder /usr/local/bin/php /usr/local/bin/php
COPY --from=builder /usr/local/lib/php /usr/local/lib/php
COPY --from=builder /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm
COPY --from=builder /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d
COPY ./php.ini /etc/php/php.ini

RUN apt update \
    && apt install -y \
    gdb \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
