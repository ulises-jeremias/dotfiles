red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
check="✓"
cross="✗"

describe() {
    printf "$1"
    dots=${2:-3}
    for i in $(seq 1 $dots); do sleep 1; printf "."; done
    sleep 1
}

log_failed() {
    message=${1:-"Failed"}
    log="${red}${cross} $message${reset}\n"
    printf " $log"
    [ -f "$2" ] && printf $log > $2
}

log_success() {
    message=${1:-"Success"}
    log="${green}${check} $message${reset}\n"
    printf " $log"
    [ -f "$2" ] && printf $log > $2
}
