ARG PHP_VERSION=7.4
FROM php:${PHP_VERSION}-apache

# use german mirrors for increased apt install and update speeds
COPY ./sources.list /etc/apt/sources.list

COPY ./scripts/build/* /build-scripts/

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
RUN install-php-extensions intl
RUN install-php-extensions gd
RUN install-php-extensions exif
#RUN install-php-extensions zip
#RUN install-php-extensions imagick      # warning: this is huge
#...


# install correct xdebug version dependent on PHP version (see https://xdebug.org/docs/compat and https://web.archive.org/web/20191207092254/https://xdebug.org/docs/compat)
RUN if [ $(printf '%s\n' 7.2 "$PHP_VERSION" | sort -V | head -n1) = "7.2" ]; then \
        install-php-extensions xdebug-^3; \
    elif [ $(printf '%s\n' 7.0 "$PHP_VERSION" | sort -V | head -n1) = "7.0" ]; then \
        install-php-extensions xdebug-^2.7; \
    elif [ $(printf '%s\n' 5.6 "$PHP_VERSION" | sort -V | head -n1) = "5.6" ]; then \
        install-php-extensions xdebug-^2.5; \
    elif [ $(printf '%s\n' 5.4 "$PHP_VERSION" | sort -V | head -n1) = "5.4" ]; then \
        install-php-extensions xdebug-^2.4; \
    else \
      echo "[ERROR] while trying to install xdebug: invalid or too old PHP version: $PHP_VERSION"; \
    fi

# install composer (more info on composer installation: https://github.com/mlocati/docker-php-extension-installer#installing-composer)
ARG INSTALL_COMPOSER="true"
RUN if [ "$INSTALL_COMPOSER" = "true" ]; then \
        install-php-extensions @composer && apt-get update && apt-get install -y unzip git; \
    fi

# install npm
ARG INSTALL_NPM="false"
RUN if [ "$INSTALL_NPM" = "true" ]; then \
           apt-get update && apt-get install -y curl \
        && curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
        && apt-get install -y nodejs; \
    fi

# install grunt-cli and sass
ARG INSTALL_GRUNT="false"
RUN if [ "$INSTALL_GRUNT" = "true" ] &&  [ "$INSTALL_NPM" = "true" ]; then \
           npm install -g grunt-cli \
        && apt-get update && apt-get install -y ruby-full \
        && gem install sass; \
    fi

# install wkhtmltopdf (https://wkhtmltopdf.org/)
ARG INSTALL_WKHTMLTOPDF="false"
RUN if [ "$INSTALL_WKHTMLTOPDF" = "true" ]; then \
       DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends wkhtmltopdf; \
    fi

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

# install wanted locales, so PHPs `setlocale(LC_ALL, 'de_DE.UTF-8')` will work
ARG INSTALL_LOCALES=""
RUN if [ -n "$INSTALL_LOCALES" ]; then \
      apt-get update && apt-get install -y locales; \
      for locale in $(echo "$INSTALL_LOCALES" | tr ',' ' '); do \
        echo "${locale}.UTF-8 UTF-8" >> /etc/locale.gen; \
      done; \
      locale-gen; \
    fi


# link php binary to /usr/bin/php for compatibility
RUN ln -s /usr/local/bin/php /usr/bin/php

# install git for merge-dirs.sh and git-submodule-update.sh script
RUN apt-get update && apt-get install -y git

# install rsync and pv for clone-into.sh
RUN apt-get update && apt-get install -y rsync