#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run as root!"
  exit 1
fi

cd "$(dirname "$0")"

install -m 100 ./integration_AV_Client /usr/local/sbin/integration_AV_Client
echo "ALL ALL=(ALL) NOPASSWD: /usr/local/sbin/integration_AV_Client" >> /etc/sudoers
install -m 555 ./mivzar-gui.sh /usr/local/bin/mivzar-gui
install -m 555 ./integration.desktop /usr/share/applications/integration.desktop
echo "Done!!"