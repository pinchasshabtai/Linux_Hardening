#!/bin/bash
log_time="/etc/verification/log_time.txt"
# יצירת קוד רנדומלי בן 4 ספרות
printf -v code "%04d" "$(shuf -i 0-9999 -n 1)"

# "שליחת" הקוד למשתמש
echo "Your code is: $code"

# קלט מהמשתמש
for i in {1..3}; do
    read -p "Enter the code you received: " input_code
    status=$(/etc/verification/Totp "$code" "$input_code")
    # בדיקה
    if [ "$status" = "VALID" ]; then
        echo "The code is correct! Unlocks the protection..."
        break
    fi

    if [ $i -eq 3 ]; then
        echo "The code is incorrect. The operation was not performed."
        exit 1
    else
        echo "The code is incorrect, please try again."
    fi
done

read -p "Should I open the protection with a scan?[y/n](Default is not) " answer

lock_time_unix=$(date -d "+60 minutes" +%s)
lock_time=$(date -d "@$lock_time_unix" +"%Y-%m-%d %H:%M:%S")

if [ ! -s "$log_time" ]; then
    # כתיבה לקובץ
    echo "$lock_time_unix" > "$log_time"
    
    if [ "$answer" = "y" ]; then
      mivzar-open-hardening -s
    else
      mivzar-open-hardening
    fi

    systemctl start check_time.timer
    systemctl enable check_time.timer

    echo "The operation was completed successfully."
    echo "The computer will lock at: $lock_time"
elif systemctl is-active --quiet fapolicy-scan; then
    echo "Hardening is already open and scanning is active, extending the time..."
    echo "$lock_time_unix" > "$log_time"
    echo "Timer extended. The computer will now lock at: $lock_time"
else
    # כבר יש רשומה – רק מרעננים את הטיימר
    echo "Hardening is already open, extending the time..."
    echo "$lock_time_unix" > "$log_time"
    echo "Timer extended. The computer will now lock at: $lock_time"
fi