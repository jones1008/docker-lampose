#!/bin/sh

if [ -z "$COMPOSE_PROJECT_NAME" ]; then
  echo "[ERROR]: required environment variable COMPOSE_PROJECT_NAME not set"
  return 1
fi

if [ -z "$DOMAIN" ]; then
  # setting DOMAIN to computed value
  echo "[INFO]: setting environment variable DOMAIN to "${COMPOSE_PROJECT_NAME}".docker"
  export DOMAIN=${COMPOSE_PROJECT_NAME}".docker"
fi


# call set-hostname.sh
sh ./_docker/web/scripts/set-hostname.sh


WD=/var/www/html

# run composer install
if [ -n "$COMPOSER_INSTALL_PATH" ]; then
  cd $WD
  cd $COMPOSER_INSTALL_PATH
  echo "[INFO]: executing composer install"
  composer install
fi

# run npm install
if [ -n "$NPM_INSTALL_PATH" ]; then
  cd $WD
  cd $NPM_INSTALL_PATH
  echo "[INFO]: executing npm install"
  npm install --no-update-notifier
fi


# start application
cd $WD
sleep 1 && echo application started at http://${DOMAIN} & exec 'apache2-foreground'