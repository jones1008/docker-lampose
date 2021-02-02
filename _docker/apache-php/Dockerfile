FROM php:7.4-apache

# enable apache module rewrite
RUN a2enmod rewrite

# install php-extension-installer for easier install of php extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

### common PHP extensions (add PHP extensions here as explained in README.md)
RUN install-php-extensions opcache  # for 2x better performance
RUN install-php-extensions pdo_mysql  # for mysqli connections
RUN install-php-extensions mysqli  # requires php7.0 or higher
#RUN install-php-extensions gd
#RUN install-php-extensions intl
#RUN install-php-extensions zip


# install correct xdebug version with script (https://xdebug.org/)
COPY ./install-xdebug.sh /
RUN /install-xdebug.sh && docker-php-ext-enable xdebug

# update apk (Alpine Package Manager) and install commonly used packages
RUN apt-get update
RUN apt-get install -y curl

# install wkhtmltopdf and it's dependencies (https://wkhtmltopdf.org/)
ARG INSTALL_WKHTMLTOPDF="false"
RUN if [ "$INSTALL_WKHTMLTOPDF" = "true" ]; then \
           apt-get install -y libxrender1 libjpeg62-turbo fontconfig libxtst6 xfonts-75dpi xfonts-base xz-utils \
        && curl "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.stretch_amd64.deb" -L -o "wkhtmltopdf.deb" \
        && dpkg -i wkhtmltopdf.deb \
    ;fi

# install composer
RUN install-php-extensions @composer-2

# removes a DNS warning at startup:
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn