FROM debian:10

LABEL "maintainer"="André Martins Pereira <andre.martins@engesoftware.com.br>"

RUN apt update \
&& apt install build-essential -y \
&& apt install vim wget locales -y

# httpd
RUN cd /srv \
    && wget https://github.com/tideeh/terracap-php5.2/raw/master/files/httpd-2.2.3.tar.gz \
    && tar -xzf httpd-2.2.3.tar.gz \
    && rm httpd-2.2.3.tar.gz
RUN cd /srv/httpd-2.2.3 \
&& ./configure --enable-so --enable-rewrite \
&& make -j4 \
&& make install

# libxml
RUN cd /srv \
    && wget https://github.com/tideeh/terracap-php5.2/raw/master/files/libxml2-2.8.0.tar.xz \
    && tar -xf libxml2-2.8.0.tar.xz \
    && rm libxml2-2.8.0.tar.xz
RUN cd /srv/libxml2-2.8.0 \
&& ./configure \
&& make -j4 \
&& make install \
&& ldconfig

# oracle
RUN apt install unzip libaio-dev -y && mkdir /opt/oracle
RUN wget https://github.com/tideeh/terracap-php5.2/raw/master/files/instantclient-basic-linux.x64-11.2.0.4.0.zip -O /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    wget https://github.com/tideeh/terracap-php5.2/raw/master/files/instantclient-sdk-linux.x64-11.2.0.4.0.zip -O /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
    unzip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip -d /opt/oracle/ && \
    unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip -d /opt/oracle/ && \
    rm /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    rm /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip
RUN echo "/opt/oracle/instantclient_11_2" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# php
# ./configure --help
RUN apt install flex libtool libpq-dev libgd-dev libcurl4-openssl-dev libmcrypt-dev -y

RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/ \
&& ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/ \
&& ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl \
&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ \
&& ln -s /opt/oracle/instantclient_11_2/libclntsh.so.11.1 /opt/oracle/instantclient_11_2/libclntsh.so \
&& mkdir /opt/oracle/client \
&& ln -s /opt/oracle/instantclient_11_2/sdk/include /opt/oracle/client/include \
&& ln -s /opt/oracle/instantclient_11_2 /opt/oracle/client/lib

RUN cd /srv  \
    && wget https://github.com/tideeh/terracap-php5.2/raw/master/files/php-5.2.17.tar.gz \
    && tar -xzf php-5.2.17.tar.gz \
    && rm php-5.2.17.tar.gz

RUN cd /srv/php-5.2.17 \
&& ./configure --with-apxs2=/usr/local/apache2/bin/apxs \
--with-pgsql \
--with-pdo-pgsql \
--with-gd \
--with-curl \
--enable-soap \
--with-mcrypt \
--enable-mbstring \
--enable-calendar \
--enable-bcmath \
--enable-zip \
--enable-exif \
--enable-ftp \
--enable-shmop \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--enable-dba \
#--with-openssl \ @TODO: deprec error libssl-dev; compile source
--with-gettext \
--with-mime-magic=/usr/local/apache2/conf/magic \
#--with-ldap \ @TODO: deprec error libldap2-dev; compile source
--with-oci8=instantclient,/opt/oracle/instantclient_11_2 \
--with-pdo-oci=instantclient,/opt/oracle,11.2 \
--with-ttf \
--with-png-dir=/usr \
--with-jpeg-dir=/usr \
--with-freetype-dir=/usr \
--with-zlib

RUN cd /srv/php-5.2.17 \
&& make -j4 \
&& make install \
&& cp php.ini-dist /usr/local/lib/php.ini

# php xdebug
RUN pecl channel-update pecl.php.net
RUN pecl install xdebug-2.2.7
RUN pecl install zendopcache-7.0.5

# php SOAP includes
RUN wget https://github.com/tideeh/terracap-php5.2/raw/master/files/soap-includes.tar.gz -O /tmp/soap-includes.tar.gz && \
    tar -xvf /tmp/soap-includes.tar.gz --directory /usr/local/lib/php/ && \
    rm /tmp/soap-includes.tar.gz