#!/bin/bash

if [ -z "$COMPOSE_PROJECT_NAME" ]; then
  echo "[ERROR]: startup.sh: required environment variable COMPOSE_PROJECT_NAME not set"
  exit 1
fi

if [ -z "$DOMAIN" ]; then
  echo "[ERROR]: startup.sh: required environment variable DOMAIN not set"
  exit 1
fi

# call build-config.sh
if ! ./_docker/web/scripts/replace-templates.sh; then
  exit 1
fi

# call set-hostname.sh
if ! ./_docker/web/scripts/set-hostname.sh; then
  exit 1
fi

wd=$(pwd)

# run composer install for each specified path
if [ -n "$COMPOSER_INSTALL_PATHS" ]; then
  for path in $(echo "$COMPOSER_INSTALL_PATHS" | tr ':' ' '); do
    cd "$wd"
    cd "$path"
    echo "[INFO]: COMPOSER: executing composer install in $path"
    composer install
  done
fi

# run npm install for each specified path
if [ -n "$NPM_INSTALL_PATHS" ]; then
  for path in $(echo "$NPM_INSTALL_PATHS" | tr ':' ' '); do
    cd "$wd"
    cd "$path"
    echo "[INFO]: NPM: executing npm install in $path"
    npm install --no-update-notifier
  done
fi


# start application
cd "$wd"

sleep 1 && \
echo "application started at https://$DOMAIN" && \
if [ -n "$EXTERNAL_IP" ]; then \
  echo "application started at http://$EXTERNAL_IP"; \
fi & \

exec 'apache2-foreground'