#!/system/bin/sh

vInternalDir="/storage/emulated/0"
vModPath="$vInternalDir/vdbay_modules"
vLogFile="$vModPath/autocut.log"
vConfFile="$vModPath/autocut.conf"

vlog() {
    echo "$(date) - $1" >"$vLogFile"
}

vnotify() {
    local vStatus="Module status: $1"
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ $vStatus ] /g" "$MODPATH/module.prop"
    am start -a android.intent.action.MAIN -e toasttext "$vStatus" -n bellavita.toast/.MainActivity
    su -lp 2000 -c "cmd notification post -S bigtext -t 'Autocut Charging AI by VDBay' tag '$vStatus'" >/dev/null 2>&1
    vlog "$1"
}

vset_charging() {
    echo "$1" >/sys/class/power_supply/charger/online
    [ "$1" = "1" ] && vnotify "Charging..." || vnotify "Discharging"
}

while true; do
    vIsScreenOff=$(dumpsys window | grep "mScreenOn" | grep false) # empty = screen on
    vIsEnabled=$(cat "$vConfFile")                                 # Read "0" or "1"
    vBatteryLevel=$(cat /sys/class/power_supply/battery/capacity)  # "0-100"
    vChargeStatus=$(cat /sys/class/power_supply/battery/status)    # "Charging" or "Discharging"

    if [ "$vIsEnabled" = "1" ]; then
        if [ "$vIsScreenOff" ]; then
            # Layar mati: Charge jika <70%, stop jika >=100%
            if [ "$vBatteryLevel" -lt 100 ] && [ "$vBatteryLevel" -ge 70 ] && [ "$vChargeStatus" = "Discharging" ]; then
                vset_charging 1
            elif [ "$vBatteryLevel" -ge 100 ] && [ "$vChargeStatus" = "Charging" ]; then
                vset_charging 0
            fi
        else
            # Layar menyala: Charge jika <30%, stop jika >=80%
            if [ "$vBatteryLevel" -lt 80 ] && [ "$vBatteryLevel" -ge 30 ] && [ "$vChargeStatus" = "Discharging" ]; then
                vset_charging 1
            elif [ "$vBatteryLevel" -ge 80 ] && [ "$vChargeStatus" = "Charging" ]; then
                vset_charging 0
            fi
        fi
    fi

    sleep 60
done &
