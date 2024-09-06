# START

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
sleep 1
ui_print "Optimize your device's battery life with VDBay AI Autocut Charging."
ui_print "- Smart, automatic charging adjustments for peak performance and longevity."
sleep 1

ui_print "Installing app..."
if pm list packages | grep -q bellavita.toast; then
    ui_print "App already installed."
else
    pm install $MODPATH/toast.apk
    if ! pm list packages | grep -q bellavita.toast; then
        ui_print "Unable to install the app. Please install it manually."
    fi
fi

nohup am start -a android.intent.action.VIEW -d https://t.me/vdbaymodule >/dev/null 2>&1 &

# END
