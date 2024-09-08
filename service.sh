#!/system/bin/sh

VINTERNALDIR=/storage/emulated/0/
VMODPATH=$VINTERNALDIR/vdbay_modules/
VLOGMOD=$MODPATH/autocut.log
VLOGINT=$VMODPATH/autocut.log
VCONFMOD=$MODPATH/autocut.conf
VCONFINT=$VMODPATH/autocut.conf

vlog() {
    echo "$(date) - $1" >$VLOGINT
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

vshow_info "Turning On..."
vshow_info "On"
VIS_ENABLED_PREV=-1 #first time "-1"
while true; do
    VIS_SCREEN_OFF=$(dumpsys window | grep "mScreenOn" | grep false)
    VIS_ENABLED=$(cat $VCONFINT) #"0", "1"
    vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV 1"
    if [ "$VIS_ENABLED" = "1" ]; then
        if [[ "$VIS_SCREEN_OFF" ]]; then
            vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV 2"
            vmode 70 99
        else
            vlog "$VIS_SCREEN_OFF = ''"
            vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV 3"
            vmode 30 80
        fi
        if [ "$VIS_ENABLED" != "$VIS_ENABLED_PREV" ]; then
            VIS_ENABLED_PREV=$VIS_ENABLED
            vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV 4"
            vshow_info "On"
        fi
        vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV 5"
    else
        if [ "$VIS_ENABLED" != "$VIS_ENABLED_PREV" ]; then
            VIS_ENABLED_PREV=$VIS_ENABLED
            vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV 6"
            vshow_info "Off"
        fi
        vlog "VIS_SCREEN_OFF = $VIS_SCREEN_OFF - VIS_ENABLED = $VIS_ENABLED - VIS_ENABLED_PREV = $VIS_ENABLED_PREV" 7
    fi
    vlog "sleep 60"
    sleep 60
done &
