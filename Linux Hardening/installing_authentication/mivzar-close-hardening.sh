#!/bin/bash

FILE="/etc/verification/log_time.txt"

if systemctl is-active --quiet fapolicy-scan; then
  #start_usbguard
  #start_nftables_firewall
  fapolicyd-scan-stop
  systemctl disable check_time.timer
  systemctl stop check_time.timer
  > "$FILE"
elif ! systemctl is-active --quiet fapolicyd; then
  #start_usbguard
  #start_nftables_firewall
  fapolicyd-enforce
  systemctl disable check_time.timer
  systemctl stop check_time.timer
  > "$FILE"
else
  echo "fapolicyd is already running."
fi
