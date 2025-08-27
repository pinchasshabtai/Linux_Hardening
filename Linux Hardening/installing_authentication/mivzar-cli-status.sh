#!/bin/bash

set -e

FILE="/etc/verification/log_time.txt"

if systemctl is-active --quiet fapolicyd; then
    echo "The computer is already locked"
else
    if [[ -s "$FILE" ]]; then       
        read -r epoch < "$FILE"
        human_date=$(date -d "@$epoch" "+%Y-%m-%d %H:%M:%S")
        echo "The computer will lock in: $human_date"
    else
        echo "The computer is unlocked by an administrator"
    fi
fi
