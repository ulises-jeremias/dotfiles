#!/usr/bin/env bash

ROOT=$(dirname $0)

. $ROOT/../../../lib/flags/declares.sh

variables["-l"]="log_file";
variables["--log-file"]="log_file";
variables["--pkgs"]="packages";

. $ROOT/../../../lib/flags/arguments.sh

. $ROOT/../../../lib/log.sh

time_str=$(date +'%m-%d-%y_%H:%M:%S')
log_file=${log_file:-"$HOME/install_progress_log_$time_str.txt"}
packages=${packages:-""}
packages=$(echo $packages | tr ',' '\n')

if [ ! -f "$log_file" ]; then
    touch $log_file
fi

if has_param '-u' "$@" || has_param '--upgrade' "$@"; then
    upgrade=true
fi

describe "Starting process" 0
echo
echo

for pkg in $packages; do
    describe "Fetching $pkg"
    if type -p $pkg > /dev/null && [ "$upgrade" != "true" ]; then
        log_success "Already installed"
        echo "$pkg INSTALLED" >> $log_file
    else
        if [ $(git ls-remote https://aur.archlinux.org/$pkg.git | wc -l) -eq 0 ]; then
            log_failed "Package not found"
            echo "$pkg FAILED TO INSTALL!!!" >> $log_file
            continue
        fi
        echo
        rm -rf /tmp/$pkg
        git clone https://aur.archlinux.org/$pkg.git /tmp/$pkg > /dev/null
        pushd /tmp/$pkg
        makepkg -si
        popd
        describe "Installing $pkg"
        if type -p $pkg > /dev/null; then
            log_success "Installed"
            echo "$pkg INSTALLED" >> $log_file
        else
            log_failed "Fialed"
            echo "$pkg FAILED TO INSTALL!!!" >> $log_file
        fi   
    fi   
done

success=$(cat $log_file | grep "INSTALLED" | wc -l)
failed=$(cat $log_file | grep "FAILED TO INSTALL!!!" | wc -l)
all=$(cat $log_file | wc -l)

echo
echo "${green}Success: ${success} ${red}Failed: ${failed}${reset} Total: $all"
