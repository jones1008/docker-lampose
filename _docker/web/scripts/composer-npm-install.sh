#!/bin/bash
# executes composer install and npm install in specified folders of the environment variables COMPOSER_INSTALL_PATHS and NPM_INSTALL_PATHS

wd=$(pwd)

# run composer install for each specified path
if [ -n "$COMPOSER_INSTALL_PATHS" ]; then
  for path in $(echo "$COMPOSER_INSTALL_PATHS" | tr ':' ' '); do
    cd "$wd" || exit 1
    cd "$path" || exit 1
    echo "[INFO]: COMPOSER: executing composer install in $path"
    composer install
  done
fi

# run npm install for each specified path
if [ -n "$NPM_INSTALL_PATHS" ]; then
  for path in $(echo "$NPM_INSTALL_PATHS" | tr ':' ' '); do
    cd "$wd" || exit 1
    cd "$path" || exit 1
    echo "[INFO]: NPM: executing npm install in $path"
    npm install --no-update-notifier
  done
fi