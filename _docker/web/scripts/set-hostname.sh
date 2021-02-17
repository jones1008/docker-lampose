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

if grep -q -P "^\s*${LOOPBACK_IP}\s+(?!${DOMAIN})" "$tmpHostsFile"; then
  # IP exists for other domain
  nextFreeIP=127.0.0.1
  # find out next free loopback IP in hosts file
  while grep -q -P "^\s*${nextFreeIP}\s+(?!${DOMAIN})" "$tmpHostsFile"; do
    IFS=. read -r oct1 oct2 oct3 oct4 <<< "$nextFreeIP"
    if [ "$oct2" = 255 ] && [ "$oct3" = 255 ] && [ "$oct4" = 254 ]; then
      echo "[ERROR]: set-hostname.sh: could not find free loopback IP"
      nextFreeIP="unavailable"
      echo "$nextFreeIP"
      break;
    elif [ "$oct3" = 255 ] && [ "$oct4" = 255 ]; then
      ((oct2++))
      oct3=0
      oct4=1
    elif [ "$oct4" = 255 ]; then
      ((oct3++))
      oct4=1
    else
      ((oct4++))
    fi
    nextFreeIP="$oct1.$oct2.$oct3.$oct4"
  done
  echo "[ERROR]: set-hostname.sh: environment variable LOOPBACK_IP $LOOPBACK_IP is already in use. Use next unused loopback IP instead: $nextFreeIP"
  exit 1
fi

if grep -q -P "^\s*(?!${LOOPBACK_IP})([0-9]{1,3}[\.]){3}[0-9]{1,3}\s+${DOMAIN}\s*$" "$tmpHostsFile"; then
  # entry exists with another IP: comment out existing entry
  echo "[WARN]: set-hostname.sh: entry for $DOMAIN already exists in hosts file '$HOSTS_FILE', commenting these lines out"
  sed -i -r "/^\s*${LOOPBACK_IP}/!s/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\s+${DOMAIN}\b"/"#&"/ "$tmpHostsFile"
  fileEdited=true
fi

if ! grep -q -P "^\s*${LOOPBACK_IP}\s+${DOMAIN}\s*$" "$tmpHostsFile"; then
  # entry doesn't exist yet

  # add newline if necessary
  last=$(tail -c 1 "$tmpHostsFile")
  if [ "$last" != "" ]; then
    printf "\r\n" >> "$tmpHostsFile"
  fi

  # add new entry
  echo "[INFO]: set-hostname.sh: adding new entry to hosts file '$HOSTS_FILE': $LOOPBACK_IP $DOMAIN"
  printf "%s %s\r\n" "$LOOPBACK_IP" "$DOMAIN" >> "$tmpHostsFile"

  fileEdited=true
fi

# write temporary hostsfile back to hostsfile
if [ "$fileEdited" = true ]; then
  cp -f "$tmpHostsFile" "$hostsFile"
fi

# remove temporary hosts file
rm "$tmpHostsFile"
