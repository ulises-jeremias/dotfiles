#!/usr/bin/env bash

NAME=$(basename "$0")
VER="0.5"

usage()
{
    cat <<- EOF

 USAGE:  $NAME [OPTIONS]

 OPTIONS:

     -h,--help          Display this message

     -v,--version       Display script version

     -r,--run           Application launcher

     -w,--window        Switch between windows

     -l,--logout        System logout dialog

     -b,--browser       Browser search by keyword (requires surfraw)

     -q,--qalculate     Persistant calculator dialog (requires libqalculate)

     -c,--clipboard     Select previous clipboard entries (requires greenclip)


  Without any options the run dialog will be opened.

EOF
}

for arg in "$@"; do
    case $arg in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo -e "$NAME -- Version $VER"
            exit 0
            ;;
        -r|--run)
            rofi -modi run,drun -show drun -line-padding 4 \
                -columns 2 -padding 50 -hide-scrollbar \
                -show-icons -drun-icon-theme "ArchLabs-Light"
            ;;
        -w|--window)
            rofi -modi window -show window -hide-scrollbar -padding 50 -line-padding 4
            ;;
        -q|--qalculate)
            hash qalc &>/dev/null ||
                { echo "Requires 'libqalculate' installed"; exit 1; }

            rofi -modi "calc:qalc +u8 -nocurrencies" -padding 50 \
                -show "calc:qalc +u8 -nocurrencies" -line-padding 4 \
                -hide-scrollbar
            ;;
        -c|--clipboard)
            hash greenclip &>/dev/null ||
                { echo "Requires 'greenclip' installed"; exit 1; }

            rofi -modi "clipboard:greenclip print" -padding 50 \
                -line-padding 4 -show "clipboard:greenclip print" \
                -hide-scrollbar
            ;;
        -b|--browser)
            hash surfraw &>/dev/null ||
                { echo "Requires 'surfraw' installed"; exit 1; }

            surfraw -browser="$BROWSER" "$(sr -elvi | awk -F'-' '{print $1}' |
                sed '/:/d' | awk '{$1=$1};1' |
                rofi -hide-scrollbar -kb-row-select 'Tab' \
                -kb-row-tab 'Control+space' -dmenu \
                -mesg 'Tab for Autocomplete' -i -p 'Web Search' \
                -padding 50 -line-padding 4)"
            ;;
        -l|--logout)
            if grep -q 'exec startx' $HOME/.*profile; then
                ANS="$(rofi -sep "|" -dmenu -i -p 'System' -width 20 \
                    -hide-scrollbar -line-padding 4 -padding 20 \
                    -lines 3 <<< " Lock| Reboot| Shutdown")"
            else
                ANS="$(rofi -sep "|" -dmenu -i -p 'System' -width 20 \
                    -hide-scrollbar -line-padding 4 -padding 20 \
                    -lines 4 <<< " Lock| Logout| Reboot| Shutdown")"
            fi

            case "$ANS" in
                *Lock) i3lock-fancy ;;
                *Reboot) systemctl reboot ;;
                *Shutdown) systemctl -i poweroff ;;
                *Logout) session-logout || pkill -15 -t tty"$XDG_VTNR" Xorg ;;
            esac
            ;;
        *)
            printf "\nOption does not exist: %s\n\n" "$arg"
            exit 2
    esac
done

(( $# == 0 )) && "$0" -r

exit 0
