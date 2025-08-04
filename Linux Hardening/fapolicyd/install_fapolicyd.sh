#!/bin/bash

set -e  # עצירה במקרה של שגיאה

if [ "$EUID" -ne 0 ]; then
  echo "Error: You must run this with sudo!"
  exit 1
fi

cd "$(dirname "$0")"

# === הגדרות נתיבים ===
DEB_DIR="./fapolicyd-offline"
SERVICE_FILE="./fapolicy-scan.service"

# === התקנת קבצי .deb ===
echo "[*] מתקין חבילות..."
dpkg -i $DEB_DIR/*.deb

# === שינוי בקובץ קונפיגורציה של fapolicyd.conf ===
echo "[*] משנה trust ל-file בקובץ הקונפיגורציה..."
sed -i 's/^trust *= *.*/trust = file/' /etc/fapolicyd/fapolicyd.conf

echo "[*] Setting permissive mode to 1 in /etc/fapolicyd/fapolicyd.conf..."
sed -i 's/^permissive *= *0/permissive = 1/' /etc/fapolicyd/fapolicyd.conf

# === יצירת תיקיית rules.d וארבעת הקבצים ===
echo "[*] יוצר את /etc/fapolicyd/rules.d ואת קבצי הכללים..."
mkdir -p /etc/fapolicyd/rules.d

touch /etc/fapolicyd/rules.d/01-deny-my-rule.rules
touch /etc/fapolicyd/rules.d/02-scan.rules
touch /etc/fapolicyd/rules.d/03-allow-my-rule.rules
touch /etc/fapolicyd/rules.d/04-deny-all.rules

echo deny_audit perm=any all : all > /etc/fapolicyd/rules.d/04-deny-all.rules
echo allow_audit perm=open all : all > /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/stop-sf >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/start-sf >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/stop_fapolicyd >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/start_fapolicyd >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/show_lock_time >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/close_hardening >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/bin/show_lock_time >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/bin/close_hardening >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules


echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/shuf >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/etc/verification/Totp >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/date >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/open_hardening >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/bin/opening_verification >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
########################
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/sbin/integration_AV_Client >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/sbin/integration_AV_Client >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/integration_AV_Client >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/local/sbin/integration_AV_Client : all >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/local/bin/start-myapp >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/local/bin/start-app >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/start-myapp >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#stop_usbguard
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/sbin/stop_usbguard >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/id >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/bin/usbguard >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/bin/sed >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/bin/systemctl >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/usbguard-dbus >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/sbin/stop_usbguard >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#stop_nftables_firewall
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/sbin/stop_nftables_firewall >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/sbin/nft >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/sbin/stop_nftables_firewall >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#start_usbguard
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/sbin/start_usbguard >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/sbin/start_usbguard >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#start_nftables_firewall
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/sbin/start_nftables_firewall >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/sbin/start_nftables_firewall >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

fagenrules --load

install -m 100 ./start_scan.sh /usr/local/sbin/start-sf
install -m 100 ./stop_scan.sh /usr/local/sbin/stop-sf
install -m 100 ./stop_fapolicyd.sh /usr/local/sbin/stop_fapolicyd
install -m 100 ./start_fapolicyd.sh /usr/local/sbin/start_fapolicyd

# === פריסת הסרוויס שלך ===
echo "[*] מתקין את הסרוויס המותאם..."
install -m 000 "$SERVICE_FILE" /etc/systemd/system/
systemctl daemon-reload
systemctl enable fapolicy-scan.service
systemctl start fapolicy-scan.service

echo "Done!"
