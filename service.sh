#!/system/bin/sh

VINTERNALDIR=/storage/emulated/0/
VMODPATH=$VINTERNALDIR/vdbay_modules/
VLOGMOD=$MODPATH/autocut.log
VLOGINT=$VMODPATH/autocut.log
VCONFMOD=$MODPATH/autocut.conf
VCONFINT=$VMODPATH/autocut.conf

vlog() {
    echo "$(date) - $1" >$VLOGMOD
}

vshow_info() {
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ Module status: $1 ] /g" "$MODPATH/module.prop"
    am start -a android.intent.action.MAIN -e toasttext "Module status: $1" -n bellavita.toast/.MainActivity
    su -lp 2000 -c "cmd notification post -S bigtext -t 'Autocut Charging AI by VDBay' tag 'Module status: $1'" >/dev/null 2>&1
    vlog "$1"
}

vmode() {
    VCHARGE_STATUS=$(cat /sys/class/power_supply/battery/status) #"Charging", "Discharging"
    VLEVEL=$(cat /sys/class/power_supply/battery/capacity)       #"0-100"

    if [ $VLEVEL -lt $1 ] && [ "$VCHARGE_STATUS" = "Discharging" ]; then
        echo 1 >/sys/class/power_supply/charger/online
        vshow_info "Charging..."
    elif [ $VLEVEL -gt $2 ] && [ "$VCHARGE_STATUS" = "Charging" ]; then
        echo 0 >/sys/class/power_supply/charger/online
        vshow_info "Discharging"
    fi
}

main_activity_module() {
    vshow_info "On"
    VIS_ENABLED_PREV=-1 #first time "-1"
    while true; do
        VIS_SCREEN_OFF=$(dumpsys window | grep "mScreenOn" | grep false)
        VIS_ENABLED=$(cat $VCONFINT) #"0", "1"

        if [ "$VIS_ENABLED" = "1" ]; then
            if [ -z "$VIS_SCREEN_OFF" ]; then
                vmode 30 80
            else
                vmode 70 99
            fi
            if [ "$VIS_ENABLED" != "$VIS_ENABLED_PREV" ]; then
                VIS_ENABLED_PREV=$VIS_ENABLED
                vshow_info "On"
            fi
        else
            if [ "$VIS_ENABLED" != "$VIS_ENABLED_PREV" ]; then
                VIS_ENABLED_PREV=$VIS_ENABLED
                vshow_info "Off"
            fi
        fi
        sleep 60
    done
}

vshow_info "Turning On..."
main_activity_module &
