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
echo "[*] Installs packages..."
dpkg -i $DEB_DIR/*.deb

# === שינוי בקובץ קונפיגורציה של fapolicyd.conf ===
echo "[*] Change the trust configuration file to file..."
sed -i 's/^trust *= *.*/trust = file/' /etc/fapolicyd/fapolicyd.conf

#echo "[*] Setting permissive mode to 1 in /etc/fapolicyd/fapolicyd.conf..."
#sed -i 's/^permissive *= *0/permissive = 1/' /etc/fapolicyd/fapolicyd.conf

# === יצירת תיקיית rules.d וארבעת הקבצים ===
echo "[*] Creates the folder and rules files..."
mkdir -p /etc/fapolicyd/rules.d

touch /etc/fapolicyd/rules.d/01-deny-my-rule.rules
touch /etc/fapolicyd/rules.d/02-scan.rules
touch /etc/fapolicyd/rules.d/03-allow-my-rule.rules
touch /etc/fapolicyd/rules.d/04-deny-all.rules

echo deny_audit perm=any all : all > /etc/fapolicyd/rules.d/04-deny-all.rules
echo allow_audit perm=open all : all > /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/fapolicyd-scan-stop >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/fapolicyd-scan >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/fapolicyd-enforce-stop >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/fapolicyd-enforce >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/mivzar-cli-status >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/mivzar-close-hardening >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/bin/mivzar-cli-status >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/bin/mivzar-close-hardening >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules


echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/shuf >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/etc/verification/Totp >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/date >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/bin/mivzar-open-hardening >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/bin/mivzar-cli >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
########################
echo allow_audit perm=any exe=/usr/bin/bash : path=/usr/local/sbin/integration_AV_Client >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/bin/sudo : path=/usr/local/sbin/integration_AV_Client >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any all : path=/usr/local/sbin/integration_AV_Client >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/local/sbin/integration_AV_Client : all >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/local/bin/start-myapp >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=any exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/local/bin/mivzar-gui >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

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

#####
echo allow_audit perm=execute exe=/usr/bin/bash : path=/usr/bin/sudo >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/bin/bash : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/bin/sudo : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/bin/sudo : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/bin/bash : path=/usr/bin/systemctl >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

echo allow_audit perm=execute exe=/usr/bin/gnome-shell : path=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/bin/gnome-shell : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules


########
echo allow_audit perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/systemd/systemd-executor >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

echo allow_audit perm=execute exe=/usr/lib/systemd/systemd-executor : path=/etc/update-motd.d/50-motd-news >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/systemd/system-environment-generators/snapd-env-generator >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/local/sbin/check_time.sh >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#mivzar-gui
echo allow_audit perm=execute exe=/usr/bin/bash : path=/usr/local/bin/mivzar-gui >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=/usr/bin/sudo : path=/usr/local/bin/mivzar-gui >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#login after lockdown
echo allow_audit perm=execute exe=/usr/libexec/gdm-session-worker : path=/usr/libexec/gdm-session-worker >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=kworker/u534:2 : path=/usr/bin/kmod >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
echo allow_audit perm=execute exe=kworker/u534:2 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#tty
allow perm=execute exe=/snap/snapd/24792/usr/bin/snap : path=/usr/bin/getent >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/snap/snapd/24792/usr/bin/snap : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/cat >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/dircolors >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/groups >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/lesspipe >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/locale-check >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/locale >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/mesg >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/tr >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/basename >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/cat >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/cut >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/date >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/dirname >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/env >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/expr >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/find >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/grep >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/id >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/mawk >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/stat >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/uname >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/xkbcomp >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/lib/ubuntu-release-upgrader/release-upgrade-motd >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/lib/update-notifier/update-motd-fsck-at-reboot >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/lib/update-notifier/update-motd-reboot-required >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/share/unattended-upgrades/update-motd-unattended-upgrades >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/env : path=/usr/bin/run-parts >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/env : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/login : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/login : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/login : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/00-header >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/10-help-text >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/50-motd-news >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/85-fwupd >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/90-updates-available >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/91-contract-ua-esm-status >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/91-release-upgrade >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/92-unattended-upgrades >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/95-hwe-eol >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/98-fsck-at-reboot >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/etc/update-motd.d/98-reboot-required >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/run-parts : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/Xwayland : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/Xwayland : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/libexec/xdg-document-portal : path=/usr/bin/fusermount3 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/libexec/xdg-document-portal : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/dbus-daemon >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/snap >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/systemctl >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/xdg-document-portal >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/xdg-permission-store >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/systemd/systemd >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/systemd/systemd-user-runtime-dir >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/systemd/user-generators/systemd-xdg-autostart-generator >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/sbin/agetty : path=/usr/bin/login >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/sbin/agetty : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/bin/dash : path=/usr/lib/sysstat/sadc >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/sysstat/sa1 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/agetty >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/sbin/cron : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
allow perm=execute exe=/usr/sbin/cron : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

#login
allow perm=execute exe=kworker/u513:5 : path=/usr/bin/kmod
allow perm=execute exe=kworker/u513:5 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=kworker/u514:1 : path=/usr/bin/kmod
allow perm=execute exe=kworker/u514:1 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=kworker/u515:2 : path=/usr/bin/kmod
allow perm=execute exe=kworker/u515:2 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=kworker/u516:27 : path=/usr/bin/kmod
allow perm=execute exe=kworker/u516:27 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=kworker/u516:29 : path=/usr/bin/kmod
allow perm=execute exe=kworker/u516:29 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd-apparmor : path=/usr/bin/systemd-detect-virt
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd-apparmor : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd : path=/usr/bin/mount
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd : path=/usr/bin/systemctl
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd : path=/usr/bin/systemd-detect-virt
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd : path=/usr/bin/udevadm
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd : path=/usr/bin/umount
allow perm=execute exe=/snap/snapd/24792/usr/lib/snapd/snapd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/dpkg-query
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/gettext
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/gnome-session
allow perm=execute exe=/usr/bin/bash : path=/usr/bin/sed
allow perm=execute exe=/usr/bin/dash : path=/etc/vmware-tools/scripts/vmware/network
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/bash
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/busctl
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/chmod
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/chown
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/df
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/dpkg-query
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/getopt
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/gettext
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/grub-editenv
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/gzip
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/ibus-daemon
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/im-launch
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/install
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/ln
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/locale
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/lsb_release
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/mkdir
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/mv
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/rm
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/run-parts
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/sed
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/seq
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/setsid
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/touch
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/tr
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/true
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/vmware-toolbox-cmd
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/which.debianutils
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/x86_64-linux-gnu-cpp-13
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/xprop
allow perm=execute exe=/usr/bin/dash : path=/usr/bin/xrdb
allow perm=execute exe=/usr/bin/dash : path=/usr/libexec/gnome-session-binary
allow perm=execute exe=/usr/bin/dash : path=/usr/libexec/ibus-x11
allow perm=execute exe=/usr/bin/dash : path=/usr/sbin/aa-status
allow perm=execute exe=/usr/bin/dash : path=/usr/sbin/apparmor_parser
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/bin/false
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/bin/gjs-console
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/bin/nautilus
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/at-spi2-registryd
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/at-spi-bus-launcher
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/gnome-shell-calendar-server
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/goa-daemon
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/goa-identity-service
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/ibus-portal
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/libexec/xdg-permission-store
allow perm=execute exe=/usr/bin/dbus-daemon : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/dbus-run-session : path=/usr/bin/dash
allow perm=execute exe=/usr/bin/dbus-run-session : path=/usr/bin/dbus-daemon
allow perm=execute exe=/usr/bin/dbus-run-session : path=/usr/bin/gnome-session
allow perm=execute exe=/usr/bin/dbus-run-session : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/dpkg : path=/usr/bin/dpkg-query
allow perm=execute exe=/usr/bin/dpkg : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/env : path=/usr/bin/dash
allow perm=execute exe=/usr/bin/env : path=/usr/bin/gjs-console
allow perm=execute exe=/usr/bin/env : path=/usr/bin/gnome-session
allow perm=execute exe=/usr/bin/gjs-console : path=/usr/bin/nautilus
allow perm=execute exe=/usr/bin/gjs-console : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/bin/env
allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/bin/ibus-daemon
allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/bin/Xwayland
allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/libexec/mutter-x11-frames
allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/share/gnome-shell/extensions/ding@rastersoft.com/app/ding.js
allow perm=execute exe=/usr/bin/gpu-manager : path=/usr/bin/dash
allow perm=execute exe=/usr/bin/gpu-manager : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/ibus-daemon : path=/usr/libexec/ibus-engine-simple
allow perm=execute exe=/usr/bin/ibus-daemon : path=/usr/libexec/ibus-extension-gtk3
allow perm=execute exe=/usr/bin/ibus-daemon : path=/usr/libexec/ibus-memconf
allow perm=execute exe=/usr/bin/ibus-daemon : path=/usr/libexec/ibus-x11
allow perm=execute exe=/usr/bin/ibus-daemon : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/ippfind : path=/usr/bin/echo
allow perm=execute exe=/usr/bin/ippfind : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/setpriv : path=/usr/bin/dconf
allow perm=execute exe=/usr/bin/setpriv : path=/usr/bin/pgrep
allow perm=execute exe=/usr/bin/setpriv : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/setsid : path=/usr/bin/setpriv
allow perm=execute exe=/usr/bin/setsid : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/ubuntu-report : path=/usr/bin/dpkg
allow perm=execute exe=/usr/bin/ubuntu-report : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/vmtoolsd : path=/etc/vmware-tools/poweron-vm-default
allow perm=execute exe=/usr/bin/vmtoolsd : path=/usr/bin/dash
allow perm=execute exe=/usr/bin/vmtoolsd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/vmware-toolbox-cmd : path=/usr/bin/dash
allow perm=execute exe=/usr/bin/vmware-toolbox-cmd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/x86_64-linux-gnu-cpp-13 : path=/usr/libexec/gcc/x86_64-linux-gnu/13/cc1
allow perm=execute exe=/usr/bin/x86_64-linux-gnu-cpp-13 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/bin/xrdb : path=/usr/bin/dash
allow perm=execute exe=/usr/bin/xrdb : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/lib/cups/daemon/cups-exec : path=/usr/lib/cups/notifier/dbus
allow perm=execute exe=/usr/lib/cups/daemon/cups-exec : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/at-spi-bus-launcher : path=/usr/bin/dbus-daemon
allow perm=execute exe=/usr/libexec/at-spi-bus-launcher : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gdm-session-worker : path=/etc/gdm3/PreSession/Default
allow perm=execute exe=/usr/libexec/gdm-session-worker : path=/usr/bin/dash
allow perm=execute exe=/usr/libexec/gdm-session-worker : path=/usr/libexec/gdm-wayland-session
allow perm=execute exe=/usr/libexec/gdm-session-worker : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gdm-wayland-session : path=/usr/bin/dbus-run-session
allow perm=execute exe=/usr/libexec/gdm-wayland-session : path=/usr/bin/env
allow perm=execute exe=/usr/libexec/gdm-wayland-session : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gnome-session-binary : path=/usr/bin/session-migration
allow perm=execute exe=/usr/libexec/gnome-session-binary : path=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop
allow perm=execute exe=/usr/libexec/gnome-session-binary : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gsd-print-notifications : path=/usr/libexec/gsd-printer
allow perm=execute exe=/usr/libexec/gsd-print-notifications : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gsd-xsettings : path=/etc/xdg/Xwayland-session.d/00-at-spi
allow perm=execute exe=/usr/libexec/gsd-xsettings : path=/etc/xdg/Xwayland-session.d/00-xrdb
allow perm=execute exe=/usr/libexec/gsd-xsettings : path=/etc/xdg/Xwayland-session.d/10-ibus-x11
allow perm=execute exe=/usr/libexec/gsd-xsettings : path=/usr/bin/dash
allow perm=execute exe=/usr/libexec/gsd-xsettings : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gvfsd-fuse : path=/usr/bin/fusermount3
allow perm=execute exe=/usr/libexec/gvfsd-fuse : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/gvfsd : path=/usr/libexec/gvfsd-fuse
allow perm=execute exe=/usr/libexec/gvfsd : path=/usr/libexec/gvfsd-trash
allow perm=execute exe=/usr/libexec/gvfsd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/libexec/packagekitd : path=/usr/bin/dpkg
allow perm=execute exe=/usr/libexec/packagekitd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/lib/snapd/snapd : path=/usr/bin/systemctl
allow perm=execute exe=/usr/lib/snapd/snapd : path=/usr/bin/systemd-detect-virt
allow perm=execute exe=/usr/lib/snapd/snapd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/chgrp
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/chmod
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/gnome-keyring-daemon
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/gnome-shell
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/gpu-manager
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/grub-editenv
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/journalctl
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/mkdir
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/mount
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/nm-online
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/pipewire
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/plymouth
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/python3.12
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/savelog
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/session-migration
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/true
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/VGAuthService
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/vmtoolsd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/bin/wireplumber
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/dconf-service
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/evolution-addressbook-factory
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/evolution-calendar-factory
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/evolution-source-registry
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gcr-ssh-agent
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gnome-remote-desktop-daemon
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gnome-session-binary
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gnome-session-ctl
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-a11y-settings
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-color
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-datetime
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-housekeeping
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-keyboard
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-media-keys
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-power
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-print-notifications
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-rfkill
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-screensaver-proxy
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-sharing
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-smartcard
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-sound
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-wacom
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gsd-xsettings
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfs-afc-volume-monitor
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfsd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfsd-metadata
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfs-goa-volume-monitor
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfs-gphoto2-volume-monitor
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfs-mtp-volume-monitor
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gvfs-udisks2-volume-monitor
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/nm-dispatcher
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/packagekitd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/tracker-miner-fs-3
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/udisks2/udisksd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/xdg-desktop-portal
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/xdg-desktop-portal-gnome
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/xdg-desktop-portal-gtk
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/xdg-desktop-portal-rewrite-launchers
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/openssh/agent-launch
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/rsyslog/reload-apparmor-profile
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/snapd/snapd-apparmor
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/snapd/snapd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/systemd/systemd-update-utmp
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/systemd/systemd-user-sessions
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/alsactl
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/anacron
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/avahi-daemon
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/cron
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/cups-browsed
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/cupsd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/gdm3
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/kerneloops
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/plymouthd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/rsyslogd
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/setvtrgb
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/sbin/wpa_supplicant
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/share/apport/apport ftype=text/x-python trust=0
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/share/gdm/generate-config
allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/share/unattended-upgrades/unattended-upgrade-shutdown ftype=text/x-python trust=0
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/dash
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/gnome-keyring-daemon
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/gnome-shell
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/snap
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/spice-vdagent
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/ubuntu-report
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/xbrlapi
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/xdg-user-dirs-gtk-update
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/xdg-user-dirs-update
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/at-spi-bus-launcher
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/evolution-data-server/evolution-alarm-notify
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-a11y-settings
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-color
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-datetime
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-disk-utility-notify
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-housekeeping
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-keyboard
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-media-keys
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-power
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-print-notifications
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-rfkill
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-screensaver-proxy
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-sharing
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-smartcard
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-sound
allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/libexec/gsd-wacom
allow perm=execute exe=/usr/sbin/cups-browsed : path=/usr/bin/ippfind
allow perm=execute exe=/usr/sbin/cups-browsed : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/sbin/cupsd : path=/usr/lib/cups/daemon/cups-exec
allow perm=execute exe=/usr/sbin/cupsd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
allow perm=execute exe=/usr/sbin/gdm3 : path=/etc/gdm3/PrimeOff/Default
allow perm=execute exe=/usr/sbin/gdm3 : path=/usr/bin/dash
allow perm=execute exe=/usr/sbin/gdm3 : path=/usr/bin/plymouth
allow perm=execute exe=/usr/sbin/gdm3 : path=/usr/libexec/gdm-session-worker
allow perm=execute exe=/usr/sbin/gdm3 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
 
#echo allow perm=execute exe=/usr/bin/bash : path=/usr/bin/dash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/bash : path=/usr/bin/dircolors >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/bash : path=/usr/bin/lesspipe >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/bash : path=/usr/bin/sudo >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/bash : path=/usr/bin/systemctl >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/bash : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/dash : path=/usr/bin/basename >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/dash : path=/usr/bin/dirname >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/dash : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/gnome-shell : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/python3.12 : path=/usr/bin/gnome-terminal.real >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/python3.12 : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/sudo : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/sudo : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/systemctl : path=/usr/bin/systemd-tty-ask-password-agent >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/bin/systemctl : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/libexec/gnome-terminal-server : path=/usr/bin/bash >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/libexec/gnome-terminal-server : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/libexec/gnome-terminal-server >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/systemd/systemd-executor : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/systemd/systemd-executor >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/systemd/systemd : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/gnome-terminal >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/bin/python3.12 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules
#echo allow perm=execute exe=/usr/lib/x86_64-linux-gnu/glib-2.0/gio-launch-desktop : path=/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 >> /etc/fapolicyd/rules.d/03-allow-my-rule.rules

fagenrules --load

install -m 100 ./fapolicyd-scan.sh /usr/local/sbin/fapolicyd-scan
install -m 100 ./fapolicyd-scan-stop.sh /usr/local/sbin/fapolicyd-scan-stop
install -m 100 ./fapolicyd-enforce-stop.sh /usr/local/sbin/fapolicyd-enforce-stop
install -m 100 ./fapolicyd-enforce.sh /usr/local/sbin/fapolicyd-enforce

# === פריסת הסרוויס שלך ===
echo "[*] Installs the scanning service..."
install -m 000 "$SERVICE_FILE" /etc/systemd/system/
systemctl daemon-reload
systemctl enable fapolicyd.service
systemctl start fapolicyd.service

echo "Done!"
