#!/system/bin/sh

# Credit to MiAzami

log_message() {
    echo "$(date) - $1" >>$MODPATH/logfile.log
}

show_toast_and_notification() {
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ Module active: $1 ] /g" "$MODPATH/module.prop" || {
        log_message "Failed to update module.prop"
        exit 1
    }
    am start -a android.intent.action.MAIN -e toasttext "Module active: $1" -n bellavita.toast/.MainActivity || {
        log_message "Failed to send toast notification"
        exit 1
    }
}

charging_mode() {
    if [ $LEVEL -lt $1 ]; then
        echo 1 >/sys/class/power_supply/charger/online || {
            log_message "Failed to start charging"
            exit 1
        }
        show_toast_and_notification "Charging in progress."
    elif [ $LEVEL -gt $2 ]; then
        echo 0 >/sys/class/power_supply/charger/online || {
            log_message "Failed to stop charging"
            exit 1
        }
        show_toast_and_notification "Charging paused."
    fi
}

main_activity_module() {
    while true; do
        CHARGE_STATUS=$(cat /sys/class/power_supply/battery/status) || {
            log_message "Failed to read charge status"
            exit 1
        }
        LEVEL=$(cat /sys/class/power_supply/battery/capacity) || {
            log_message "Failed to read battery level"
            exit 1
        }
        SCREEN_STATE=$(dumpsys nfc | grep 'mScreenState' | cut -d'=' -f2) || {
            log_message "Failed to get screen state"
            exit 1
        }
        IS_POWER_SAVE=$(dumpsys nfc | grep 'mIsPowerSavingModeEnabled' | cut -d'=' -f2) || {
            log_message "Failed to get power save status"
            exit 1
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
