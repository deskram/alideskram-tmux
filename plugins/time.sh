#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

time_format=$(get_tmux_option "@alideskram-time-format" "%a %I:%M %p")
time_icon=$(get_tmux_option "@alideskram-time-icon" "")

main() {
    date +"$time_icon $time_format"
}

main
