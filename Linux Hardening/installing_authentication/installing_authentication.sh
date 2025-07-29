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
install -m 100 ./cli.sh /usr/local/bin/opening_verification
install -m 100 ./show_lock_time.sh /usr/local/bin/show_lock_time
install -m 100 ./close_hardening.sh /usr/local/bin/close_hardening
install -m 100 ./open_hardening.sh /usr/local/bin/open_hardening

echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/opening_verification" >> /etc/sudoers
echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/show_lock_time" >> /etc/sudoers
echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/close_hardening" >> /etc/sudoers
echo "alias open-hardening-verify='sudo opening_verification'" >> /etc/bash.bashrc
echo "alias show-lock-time='sudo show_lock_time'" >> /etc/bash.bashrc
echo "alias close-hardening='sudo close_hardening'" >> /etc/bash.bashrc
source /etc/bash.bashrc

echo "[+] Refreshes the services."
systemctl daemon-reload

echo "[+] Done!"
