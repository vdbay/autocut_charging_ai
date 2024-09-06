#!/system/bin/sh

# Credit to MiAzami

log_message() {
    echo "$(date) - $1" >>$MODPATH/logfile.log
}

show_toast_and_notification() {
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ Module active: $1 ] /g" "$MODPATH/module.prop" || {
        log_message "Failed to update module.prop"
    }
    am start -a android.intent.action.MAIN -e toasttext "Module active: $1" -n bellavita.toast/.MainActivity || {
        log_message "Failed to send toast notification"
    }
}

charging_mode() {
    if [ $LEVEL -lt $1 ]; then
        echo 1 >/sys/class/power_supply/charger/online || {
            log_message "Failed to start charging"
        }
        show_toast_and_notification "Charging in progress."
    elif [ $LEVEL -gt $2 ]; then
        echo 0 >/sys/class/power_supply/charger/online || {
            log_message "Failed to stop charging"
        }
        show_toast_and_notification "Charging paused."
    fi
}

main_activity_module() {
    PREV_CHARGING_MODE=" "
    while true; do
        CHARGE_STATUS=$(cat /sys/class/power_supply/battery/status) || {
            log_message "Failed to read charge status"
        }
        LEVEL=$(cat /sys/class/power_supply/battery/capacity) || {
            log_message "Failed to read battery level"
        }
        SCREEN_STATE=$(dumpsys nfc | grep 'mScreenState' | cut -d'=' -f2) || {
            log_message "Failed to get screen state"
        }
        IS_POWER_SAVE=$(dumpsys nfc | grep 'mIsPowerSavingModeEnabled' | cut -d'=' -f2) || {
            log_message "Failed to get power save status"
        }

        if [ "$CHARGE_STATUS" != "Charging" ]; then
            if [ "$PREV_CHARGING_MODE" != "X" ]; then
                show_toast_and_notification "Device is not charging."
            fi

            sleep 90
        else
            if [ "$SCREEN_STATE" = "ON_UNLOCKED" ] && [ "$IS_POWER_SAVE" != "true" ]; then
                if [ "$PREV_CHARGING_MODE" != "A" ]; then
                    charging_mode 30 80
                fi
            else
                if [ "$PREV_CHARGING_MODE" != "B" ]; then
                    charging_mode 60 90
                fi
            fi
            sleep 60
        fi
    done
}

log_message "executed"
su -lp 2000 -c "cmd notification post -S bigtext -t 'Autocut Charging AI' tag 'Module active: Starting...'" >/dev/null 2>&1
main_activity_module &
