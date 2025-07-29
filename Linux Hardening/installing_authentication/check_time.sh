#!/bin/bash

FILE="/etc/verification/log_time.txt"
read -r target_epoch < "$FILE"
now_epoch=$(date +%s)

if (( target_epoch <= now_epoch )); then
    close_hardening
fi
