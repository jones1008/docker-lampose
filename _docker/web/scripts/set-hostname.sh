#!/bin/sh
# this script adds entries to the hosts file

if [ -z "$LOOPBACK_IP" ]; then
  echo "[ERROR]: required environment variable LOOPBACK_IP is not set"
  return 1
fi

if [ -z "$DOMAIN" ]; then
  echo "[ERROR]: required environment variable DOMAIN is not set"
  return 1
fi

HOSTSFILE=/tmp/hostsfile
TMPHOSTSFILE=/tmp/tmphostsfile
FILE_EDITED=false

# copy hosts file to temporary to avoid "Device or resource busy" error
cp "$HOSTSFILE" "$TMPHOSTSFILE"

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