red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
check="✓"
cross="✗"
warn="⚠"

describe() {
    printf "$1"
    dots=${2:-3}
    for i in $(seq 1 $dots); do sleep 0.035; printf "."; done
    sleep 0.035
}

log_warn() {
    message=${1:-"Warning"}
    log="$yellow$warn $message$reset\n"
    printf " $log"
    [ -f "$3" ] && printf "$2 $log" >> $3
}

log_failed() {
    message=${1:-"Failed"}
    log="$red$cross $message$reset\n"
    printf " $log"
    [ -f "$3" ] && printf "$2 $log" >> $3
}

log_success() {
    message=${1:-"Success"}
    log="$green$check $message$reset\n"
    printf " $log"
    [ -f "$3" ] && printf "$2 $log" >> $3
}
