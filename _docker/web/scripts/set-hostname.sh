#!/bin/bash
# this script adds entries to the hosts file

if [ -z "$LOOPBACK_IP" ]; then
  echo "[ERROR]: set-hostname.sh: required environment variable LOOPBACK_IP is not set"
  exit 1
fi

if [ -z "$DOMAIN" ]; then
  echo "[ERROR]: set-hostname.sh: required environment variable DOMAIN is not set"
  exit 1
fi

hostsFile=/tmp/hostsfile
tmpHostsFile=/tmp/tmphostsfile
fileEdited=false

# copy hosts file to temporary to avoid "Device or resource busy" error
cp "$hostsFile" "$tmpHostsFile"

if grep -q -P "^\s*(?!${LOOPBACK_IP})([0-9]{1,3}[\.]){3}[0-9]{1,3}\s+${DOMAIN}\s*$" "$tmpHostsFile"; then
  # entry exists with another IP: comment out existing entry
  echo "[WARN]: set-hostname.sh: entry for $DOMAIN already exists in hosts file, commenting these lines out"
  sed -i -r "/^\s*${LOOPBACK_IP}/!s/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\s+${DOMAIN}\b"/"#&"/ "$tmpHostsFile"
  fileEdited=true
fi

if grep -q -P "^\s*${LOOPBACK_IP}\s+(?!${DOMAIN})\s*$" "$tmpHostsFile"; then
  # IP exists for other domain
  echo "[WARN]: set-hostname.sh: entry for $LOOPBACK_IP with another domain already exists. This may lead to container hostname conflicts"
fi

if ! grep -q -P "^\s*${LOOPBACK_IP}\s+${DOMAIN}\s*$" "$tmpHostsFile"; then
  # entry doesn't exist yet

  # add newline if necessary
  last=$(tail -c 1 "$tmpHostsFile")
  if [ "$last" != "" ]; then
    printf "\r\n" >> "$tmpHostsFile"
  fi

  # add new entry
  echo "[INFO]: set-hostname.sh: adding new entry: $LOOPBACK_IP $DOMAIN"
  printf "%s %s\r\n" "$LOOPBACK_IP" "$DOMAIN" >> "$tmpHostsFile"

  fileEdited=true
fi

# write temporary hostsfile back to hostsfile
if [ "$fileEdited" = true ]; then
  cp -f "$tmpHostsFile" "$hostsFile"
fi

# remove temporary hosts file
rm "$tmpHostsFile"