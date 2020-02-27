#!/usr/bin/env bash

BAR_ICON=""
NOTIFIED=0
NOTIFY_ICON=/usr/share/icons/gnome/32x32/apps/system-software-update.png

get_total_updates()
{
    UPDATES=$(checkupdates 2>/dev/null | wc -l)
}

while true; do
    # print the icon first to avoid gibberish in polybar
    echo $BAR_ICON

    get_total_updates

    # notify user of updates
    if (( NOTIFIED == 0 )) && hash notify-send >/dev/null 2>&1; then
        if (( UPDATES > 50 )); then
            notify-send -u critical -i $NOTIFY_ICON "Updates Available" "$UPDATES packages"
        elif (( UPDATES > 25 )); then
            notify-send -u normal -i $NOTIFY_ICON "Updates Available"  "$UPDATES packages"
        elif (( UPDATES > 2 )); then
            notify-send -u low -i $NOTIFY_ICON "Updates Available" "$UPDATES packages"
        fi
        NOTIFIED=1
    fi

    # when there are updates available
    # every 10 seconds another check for updates is done
    while (( UPDATES > 0 )); do
        (( UPDATES == 1 )) && echo "$UPDATES Update" || { (( UPDATES > 1 )) && echo "$UPDATES Updates"; }
        sleep 10
        get_total_updates
    done

    # when no updates are available, use a longer loop, this saves on CPU
    # and network uptime, only checking once every 30 min for new updates
    while (( UPDATES == 0 )); do
        sleep 1800
        get_total_updates
    done
done
