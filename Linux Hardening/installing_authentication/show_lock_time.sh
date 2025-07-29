#!/bin/bash

set -e

FILE="/etc/verification/log_time.txt"

if [[ ! -s "$FILE" ]]; then
    echo "The computer is already locked"
    exit 0
fi

read -r epoch < "$FILE"

human_date=$(date -d "@$epoch" "+%Y-%m-%d %H:%M:%S")

echo "The computer will lock in: $human_date"
