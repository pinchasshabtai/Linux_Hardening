#!/bin/bash

set -e  # עצירה במקרה של שגיאה

if [ "$EUID" -ne 0 ]; then
  echo "Error: You must run this with sudo!"
  exit 1
fi

if ! systemctl is-active --quiet fapolicy-scan; then
  echo "The scan did not run."
  exit 1
  if systemctl is-active --quiet fapolicyd; then
    echo "fapolicyd is already running."
    exit 1
  else 
    systemctl enable fapolicyd
    systemctl start fapolicyd
    exit 1
  fi
fi

# עוצרים את הסרוויס fapolicy-scan.service
systemctl stop fapolicy-scan.service

# עושים disable לסרוויס הזה
systemctl disable fapolicy-scan.service

# מגדירים נתיבים
LOGFILE="/etc/fapolicyd/fapolicy-scan-log.output"
RULES_DIR="/etc/fapolicyd/rules.d"
RULE_02="$RULES_DIR/02-scan.rules"
CONF_FILE="/etc/fapolicyd/fapolicyd.conf"

# בודקים אם קובץ הלוג קיים
if [[ ! -f "$LOGFILE" ]]; then
  echo "[!] File not found: $LOGFILE"
  exit 1
fi

# מעבדים את הקובץ וכותבים לפלט
sed -i -e '/dec=/!d' -e's/.*dec=//' -e's/ pid=[^ ]*//' -e 's/ auid=[^ ]*//' -e 's/deny_audit/allow/' "$LOGFILE"
tee -a "$LOGFILE" < "$RULE_02" > /dev/null
sort "$LOGFILE" | uniq | sudo tee "$LOGFILE.tmp" > /dev/null && sudo mv "$LOGFILE.tmp" "$LOGFILE"
cp "$LOGFILE" "$RULE_02"

echo "" | sudo tee "$LOGFILE" > /dev/null

# טוענים את החוקים החדשים
fagenrules --load

# משנים את permissive ל-0 בקובץ הקונפיג

sed -i 's/^permissive *= *1/permissive = 0/' "$CONF_FILE"

# מפעילים את הסרוויס fapolicyd
systemctl enable fapolicyd
systemctl start fapolicyd

echo "[+] All done."