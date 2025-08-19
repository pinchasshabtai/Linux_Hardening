#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run as root!"
  exit 1
fi

cd "$(dirname "$0")"

echo "[+] Creates a folder."
install -d -m 700 -o root -g root /etc/verification

echo "[+] Creates a time file."
sudo install -m 600 /dev/null /etc/verification/log_time.txt

echo "[+] Copies the service files."
install -m 100 ./check_time.sh /usr/local/sbin/
install -m 000 ./check_time.service /etc/systemd/system/
install -m 000 ./check_time.timer /etc/systemd/system/

echo "[+] Copying the verification file."
install -m 100 ./Totp /etc/verification/

echo "[+] Copying the CLI interface."
install -m 100 ./mivzar-cli /usr/local/bin/mivzar-cli
install -m 100 ./mivzar-cli-status.sh /usr/local/bin/mivzar-cli-status
install -m 100 ./mivzar-close-hardening.sh /usr/local/bin/mivzar-close-hardening
install -m 100 ./mivzar-open-hardening.sh /usr/local/bin/mivzar-open-hardening

echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/mivzar-cli" >> /etc/sudoers
echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/mivzar-cli-status" >> /etc/sudoers
echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/mivzar-close-hardening" >> /etc/sudoers
echo "alias mivzar-cli='sudo mivzar-cli'" >> /etc/bash.bashrc
echo "alias mivzar-cli-status='sudo mivzar-cli-status'" >> /etc/bash.bashrc
echo "alias mivzar-close-hardening='sudo mivzar-close-hardening'" >> /etc/bash.bashrc
source /etc/bash.bashrc

echo "[+] Refreshes the services."
systemctl daemon-reload

echo "[+] Done!"
