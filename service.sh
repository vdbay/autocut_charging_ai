#!/system/bin/sh

# Credit to MiAzami

log_message() {
    echo "$(date) - $1" >>$MODPATH/logfile.log
}

show_toast_and_notification() {
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ Module active: $1 ] /g" "$MODPATH/module.prop" || {
        log_message "Failed to update module.prop"
    }
    am start -a android.intent.action.MAIN -e toasttext "🌱 Sakura will grow." -n bellavita.toast/.MainActivity
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
            show_toast_and_notification "Device is not charging."
            sleep 90
        else
            if [ "$SCREEN_STATE" = "ON_UNLOCKED" ] && [ "$IS_POWER_SAVE" != "true" ]; then
                charging_mode 30 80
            else
                charging_mode 60 90
            fi
            sleep 60
        fi
    done
}

log_message "executed"
main_activity_module &
