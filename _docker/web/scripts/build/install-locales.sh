#!/bin/bash
# WARN: any change in this script requires a docker container rebuild to take effect

locales=$1

if [ -n "$locales" ]; then
  apt-get update && apt-get install -y locales
  for locale in $(echo "$locales" | tr ',' ' '); do
    echo "${locale}.UTF-8 UTF-8" >> /etc/locale.gen
  done
  locale-gen
fi
