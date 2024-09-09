# START

VINTERNALDIR=/storage/emulated/0/
VMODPATH=$VINTERNALDIR/vdbay_modules/
VLOGMOD=$MODPATH/autocut.log
VLOGINT=$VMODPATH/autocut.log
VCONFMOD=$MODPATH/autocut.conf
VCONFINT=$VMODPATH/autocut.conf

sleep 1
ui_print " "
ui_print "    ___    ____                                   "
ui_print "   /   |  /  _/                                   "
ui_print "  / /| |  / /                                     "
ui_print " / ___ |_/ /                                      "
ui_print "/_/  |_/___/                                      "
ui_print "    ___   __  ____________  ________  ________    "
ui_print "   /   | / / / /_  __/ __ \/ ____/ / / /_  __/    "
ui_print "  / /| |/ / / / / / / / / / /   / / / / / /       "
ui_print " / ___ / /_/ / / / / /_/ / /___/ /_/ / / /        "
ui_print "/_/  |_\____/ /_/  \____/\____/\____/ /_/         "
ui_print "   ________  _____    ____  ___________   ________"
ui_print "  / ____/ / / /   |  / __ \/ ____/  _/ | / / ____/"
ui_print " / /   / /_/ / /| | / /_/ / / __ / //  |/ / / __  "
ui_print "/ /___/ __  / ___ |/ _, _/ /_/ // // /|  / /_/ /  "
ui_print "\____/_/ /_/_/  |_/_/ |_|\____/___/_/ |_/\____/   "
ui_print "    ______  __   _    ______  ____  _____  __     "
ui_print "   / __ ) \/ /  | |  / / __ \/ __ )/   \ \/ /     "
ui_print "  / __  |\  /   | | / / / / / __  / /| |\  /      "
ui_print " / /_/ / / /    | |/ / /_/ / /_/ / ___ |/ /       "
ui_print "/_____/ /_/     |___/_____/_____/_/  |_/_/        "
ui_print "                                                  "
ui_print " "

# Check compatibility
VIS_COMPATIBLE=$(wc -c <"$MODPATH/service.sh")
if [ "$VIS_COMPATIBLE" = "1593"]; then
    abort "Not compatible, can't install. Please ask your maintainer."
fi

ui_print "Installing app..."
if pm list packages | grep -q bellavita.toast; then
    ui_print "App already installed."
else
    pm install $MODPATH/toast.apk
    if ! pm list packages | grep -q bellavita.toast; then
        ui_print "Unable to install the app. Please install it manually."
    fi
fi

ui_print "Adding configuration..."
if [ ! -e "$VMODPATH" ]; then
    mkdir $VMODPATH
    if [ ! -e "$VLOGINT" ]; then
        cp -f "$VLOGMOD" "$VLOGINT"
        echo "$(date) - Installed" >$VLOGINT
    fi
    if [ ! -e "$VCONFINT" ]; then
        cp -f "$VCONFMOD" "$VCONFINT"
    fi
fi
ui_print "Thanks to:"
ui_print "- MiAzami"
ui_print "- Tester"
ui_print "- Follower/Subscriber"
ui_print "- Topjohnwu"
ui_print "- Zackptg5"

nohup am start -a android.intent.action.VIEW -d https://t.me/vdbaymodule >/dev/null 2>&1 &

# END
