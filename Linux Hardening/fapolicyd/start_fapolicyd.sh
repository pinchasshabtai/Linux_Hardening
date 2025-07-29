#!/bin/bash

set -e  # עצירה במקרה של שגיאה

if [ "$EUID" -ne 0 ]; then
  echo "Error: You must run this with sudo!"
  exit 1
fi

if systemctl is-active --quiet fapolicyd; then
  echo "fapolicyd is already running."
else 
  echo "[*] Enabling and starting fapolicyd service..."
  systemctl enable fapolicyd
  systemctl start fapolicyd
fi

echo "[+]Done!"
