#!/bin/bash

set -e  # עצירה במקרה של שגיאה

if [ "$EUID" -ne 0 ]; then
  echo "Error: You must run this with sudo!"
  exit 1
fi

if systemctl is-active --quiet fapolicy-scan; then
  echo "The scan is already running."
  exit 1
fi

if systemctl is-active --quiet fapolicyd; then
  echo "[*] Stopping and disabling fapolicyd service..."
  systemctl stop fapolicyd
  systemctl disable fapolicyd
else
  echo "fapolicyd not running."
fi

echo "[*] Setting permissive mode to 1 in /etc/fapolicyd/fapolicyd.conf..."
sed -i 's/^permissive *= *0/permissive = 1/' /etc/fapolicyd/fapolicyd.conf

echo "[*] Enabling and starting fapolicy-scan.service..."
systemctl enable fapolicy-scan.service
systemctl start fapolicy-scan.service

echo "[+] Done."
