#!/bin/sh

# this script adds entries to the hosts file

COMPOSE_PROJECT_NAME=$1
LOOPBACK_IP=$2
DOMAIN=$3

HOSTSFILE=/tmp/hostsfile
TMPHOSTSFILE=/tmp/tmphostsfile
FILE_EDITED=false

if [ -n "$LOOPBACK_IP" ]; then

  # copy hosts file to temporary to avoid "Device or resource busy" error
  cp "$HOSTSFILE" "$TMPHOSTSFILE"

  if [ -z "$DOMAIN" ]; then
    # setting DOMAIN to computed value
    echo "[INFO]: HOSTSFILE: setting DOMAIN to "${COMPOSE_PROJECT_NAME}".local"
    DOMAIN=${COMPOSE_PROJECT_NAME}".local"
  fi

  if grep -q -P "^\s*(?!${LOOPBACK_IP})([0-9]{1,3}[\.]){3}[0-9]{1,3}\s+${DOMAIN}" "$TMPHOSTSFILE"; then
    # entry exists with another IP: comment out existing entry
    echo "[WARN]: HOSTSFILE: entry for "${DOMAIN}" already exists in hosts file, commenting these lines out"
    sed -i -r "/^\s*${LOOPBACK_IP}/!s/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\s+$DOMAIN\b"/"#&"/ "$TMPHOSTSFILE"
    FILE_EDITED=true
  fi

  if grep -q -P "^\s*${LOOPBACK_IP}\s+(?!${DOMAIN})" "$TMPHOSTSFILE"; then
    # IP exists for other domain
    echo "[WARN]: HOSTSFILE: entry for "${LOOPBACK_IP}" with another domain exists"
  fi

  if ! grep -q -P "^\s*${LOOPBACK_IP}\s+${DOMAIN}" "$TMPHOSTSFILE"; then
    # entry doesn't exist yet

    # add newline if necessary
    last=$(tail -c 1 "$TMPHOSTSFILE")
    if [ "$last" != "" ]; then
      echo "\r\n" >> "$TMPHOSTSFILE"
    fi

    # add new entry
    echo "[INFO]: HOSTSFILE: adding new entry: "${LOOPBACK_IP}" "${DOMAIN}
    echo $LOOPBACK_IP" "$DOMAIN"\r\n" >> "$TMPHOSTSFILE"

    FILE_EDITED=true
  fi

  # write temporary hostsfile back to hostsfile
  if [ "$FILE_EDITED" = true ]; then
    cp -f "$TMPHOSTSFILE" "$HOSTSFILE"
  fi

  # remove temporary hosts file
  rm "$TMPHOSTSFILE"

  # start application
  sleep 1 && echo application started at http://${DOMAIN} & exec 'apache2-foreground'

else
  echo "[ERROR]: HOSTSFILE: Environment variable LOOPBACK_IP is not set"
  return 1
fi