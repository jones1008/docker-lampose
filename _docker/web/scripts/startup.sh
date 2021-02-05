#!/bin/sh
# WARN: any change in this script requires a docker container rebuild to take effect

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