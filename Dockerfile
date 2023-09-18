FROM php:8.0-apache

ENV GLPI_VERSION=10.0.6
ENV GLPI_URL=https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz
ENV TERM=xterm

RUN mkdir -p /usr/src/php/ext/ && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free">/etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free">>/etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free">>/etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free">>/etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian bullseye pve-no-subscription">>/etc/apt/sources.list && \
  apt-get update || echo "go on..."

RUN apt-get install -y gnupg2 && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DD4BA3917E23BF59

RUN apt-get update --no-install-recommends -yqq && \
	apt-get install --no-install-recommends -yqq \
	zlib1g \
	cron \
	bzip2 \
	wget \
	nano

RUN apt-get install -y libz-dev && \
apt-get install -y libzip-dev && \
    curl -o zip.tgz -SL http://pecl.php.net/get/zip-1.22.2.tgz && \
       tar -xf zip.tgz -C /usr/src/php/ext/ && \
        rm zip.tgz && \
      	mv /usr/src/php/ext/zip-1.22.2 /usr/src/php/ext/zip && \
		docker-php-ext-install zip

RUN apt-get install --no-install-recommends -y libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
	docker-php-ext-install ldap

RUN apt-get install -y apache2 python-dev

RUN a2enmod rewrite expires

RUN apt-get install --no-install-recommends -yqq libssl-dev libc-client2007e-dev libkrb5-dev && \
    docker-php-ext-configure imap --with-imap-ssl --with-kerberos && \
    docker-php-ext-install imap

RUN apt-get install --no-install-recommends -yqq libbz2-dev && \
	docker-php-ext-install bz2

RUN apt-get install --no-install-recommends -yqq  re2c libmcrypt-dev libmcrypt4 libmcrypt-dev && \
    curl -o mcrypt.tgz -SL http://pecl.php.net/get/mcrypt-1.0.6.tgz && \
        tar -xf mcrypt.tgz -C /usr/src/php/ext/ && \
        rm mcrypt.tgz && \ 
        mv /usr/src/php/ext/mcrypt-1.0.6 /usr/src/php/ext/mcrypt && \
		docker-php-ext-install mcrypt

RUN apt-get --no-install-recommends -yqq  install zlib1g-dev && \
    docker-php-ext-install zip && \
    apt-get purge --auto-remove -y zlib1g-dev

RUN docker-php-ext-install mysqli

RUN docker-php-ext-install pdo_mysql

RUN apt-get --no-install-recommends -yqq  install libxml2-dev && \
	docker-php-ext-install soap

RUN apt-get --no-install-recommends -yqq  install libxslt-dev && \
    curl -o xmlrpc.tgz -SL http://pecl.php.net/get/xmlrpc-1.0.0RC3.tgz && \
        tar -xf xmlrpc.tgz -C /usr/src/php/ext/ && \
        rm xmlrpc.tgz && \ 
        mv /usr/src/php/ext/xmlrpc-1.0.0RC3 /usr/src/php/ext/xmlrpc && \
	docker-php-ext-install xmlrpc xsl

RUN curl -o apcu.tgz -SL http://pecl.php.net/get/apcu-5.1.22.tgz && \
	tar -xf apcu.tgz -C /usr/src/php/ext/ && \
	rm apcu.tgz && \
	mv /usr/src/php/ext/apcu-5.1.22 /usr/src/php/ext/apcu && \
	docker-php-ext-install apcu

RUN apt-get install --no-install-recommends --fix-missing -yqq libicu-dev libfreetype6-dev libpng-dev libpng16-16 libjpeg-dev libjpeg62-turbo-dev libzip-dev && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/   && \
	docker-php-ext-install gd && \
    docker-php-ext-install intl && \
    docker-php-ext-install exif



RUN docker-php-ext-install opcache && \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

COPY glpi-10.0.6.tgz /var/www/html/glpi-10.0.6.tgz

RUN cd /var/www/html && \
	tar --strip-components=1 -xvf glpi-${GLPI_VERSION}.tgz && \
	rm -f glpi-${GLPI_VERSION}.tgz


RUN chown -R www-data:www-data /var/www/html/


COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN  chmod +x /docker-entrypoint.sh

RUN  mkdir -p /var/www/html/files/_cache && \
	 chmod -R 775 /var/www/html/files/_cache && \
	 chown www-data:www-data /var/www/html/files/_cache

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["sleep", "infinity"]
