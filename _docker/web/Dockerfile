FROM php:7.4-apache

# use german mirrors for increased apt install and update speeds
COPY ./sources.list /etc/apt/sources.list

WORKDIR /var/www/html

# enable apache module rewrite
RUN a2enmod rewrite
RUN a2enmod ssl && a2ensite default-ssl

# install php-extension-installer for easier install of php extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

### common PHP extensions (add PHP extensions here as explained in README.md)
# see all available PHP extensions at https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions
RUN install-php-extensions opcache      # for 2x better performance
RUN install-php-extensions pdo_mysql    # for mysqli connections
RUN install-php-extensions mysqli       # requires php7.0 or higher
#RUN install-php-extensions gd
#RUN install-php-extensions intl
#RUN install-php-extensions zip
#RUN install-php-extensions imagick      # warning: this is huge
#...


# install correct xdebug version with script (https://xdebug.org/)
COPY ./scripts/install-xdebug.sh /install-xdebug.sh
RUN /install-xdebug.sh
RUN docker-php-ext-enable xdebug


# install composer (more info on composer installation: https://github.com/mlocati/docker-php-extension-installer#installing-composer)
RUN install-php-extensions @composer && apt-get update && apt-get install -y unzip git

# prepare other installations
RUN apt-get update && apt-get install -y curl

# install npm
RUN apt-get update && apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# install grunt-cli
RUN npm install -g grunt-cli

# install wkhtmltopdf (https://wkhtmltopdf.org/)
ARG INSTALL_WKHTMLTOPDF="false"
RUN if [ "$INSTALL_WKHTMLTOPDF" = "true" ]; then \
       DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends wkhtmltopdf \
    ;fi

# setup mail catcher (iptables and mailhog)
RUN apt-get update && apt-get install -y iptables
RUN apt-get update && apt-get install -y golang-go git \
    && mkdir /root/go \
    && export GOPATH=/root/go \
    && go get github.com/mailhog/MailHog \
    && mv /root/go/bin/MailHog /usr/local/bin \
    && rm -rf /root/go \
    && apt-get purge -y golang-go

# removes a DNS warning at startup:
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn