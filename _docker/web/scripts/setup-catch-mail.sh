#!/bin/bash

portsToReroute=("25" "465" "587")

echo "[INFO]: setup-catch-mail.sh: adding IP table entries to reroute outgoing mail traffic on ports ${portsToReroute[*]}"

for port in "${portsToReroute[@]}"; do
  iptables -t nat -A OUTPUT -p tcp --dport "${port}" -j DNAT --to-destination 127.0.0.1:1025
done

MailHog &>/dev/null &
