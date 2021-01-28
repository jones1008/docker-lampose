FROM php:7.4-apache

### add PHP extensions here as explained in README.md:


# install correct xdebug version with script
COPY ./install-xdebug.sh /
RUN /install-xdebug.sh && \
    docker-php-ext-enable xdebug


# install wkhtmltopdf and it's dependencies
ARG INSTALL_WKHTMLTOPDF="false"
RUN if [ "$INSTALL_WKHTMLTOPDF" = "true" ]; then \
        apt-get update && \
        apt-get install -y \
            curl \
            libxrender1 \
            libjpeg62-turbo \
            fontconfig \
            libxtst6 \
            xfonts-75dpi \
            xfonts-base \
            xz-utils && \
        curl "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.stretch_amd64.deb" -L -o "wkhtmltopdf.deb" && \
        dpkg -i wkhtmltopdf.deb \
    ;fi