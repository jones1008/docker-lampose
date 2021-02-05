#!/bin/sh

if [ -z "$COMPOSE_PROJECT_NAME" ]; then
  echo "[ERROR]: startup.sh: required environment variable COMPOSE_PROJECT_NAME not set"
  return 1
fi

if [ -z "$DOMAIN" ]; then
  # setting DOMAIN to computed value
  echo "[INFO]: startup.sh: setting environment variable DOMAIN to "${COMPOSE_PROJECT_NAME}".docker"
  export DOMAIN=${COMPOSE_PROJECT_NAME}".docker"
fi


# call set-hostname.sh
sh ./_docker/web/scripts/set-hostname.sh

wd=$(pwd)

# run composer install for each specified path
if [ -n "$COMPOSER_INSTALL_PATHS" ]; then
  for path in $(echo $COMPOSER_INSTALL_PATHS | tr ':' ' '); do
    cd $wd
    cd $path
    echo "[INFO]: COMPOSER: executing composer install in "$path
    composer install
  done
fi

# run npm install for each specified path
if [ -n "$NPM_INSTALL_PATHS" ]; then
  for path in $(echo $NPM_INSTALL_PATHS | tr ':' ' '); do
    cd $wd
    cd $path
    echo "[INFO]: NPM: executing npm install in "$path
    npm install --no-update-notifier
  done
fi


# start application
cd $wd
sleep 1 && echo application started at http://${DOMAIN} & exec 'apache2-foreground'