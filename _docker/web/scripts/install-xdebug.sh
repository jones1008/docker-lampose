#!/bin/bash
# WARN: any change in this script requires a docker container rebuild to take effect

# xdebug versions with PHP versions see: https://xdebug.org/docs/compat and https://web.archive.org/web/20191207092254/https://xdebug.org/docs/compat

phpFullVersion=$(php -v | grep ^PHP | cut -d' ' -f2)

# greater than equal function for php version numbers
gte() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ]
}

if gte 7.2 $phpFullVersion; then
  echo "installing xdebug 3.0.2"
  pecl install xdebug-3.0.2
elif gte 7.0 $phpFullVersion; then
  echo "installing xdebug 2.7.2"
  pecl install xdebug-2.7.2
elif gte 5.6 $phpFullVersion; then
  echo "installing xdebug 2.5.5"
  pecl install xdebug-2.5.5
elif gte 5.4 $phpFullVersion; then
  echo "installing xdebug 2.4.1"
  pecl install xdebug-2.4.1
else
  echo "[ERROR] while trying to install xdebug: invalid or too old version number: "$phpFullVersion
fi