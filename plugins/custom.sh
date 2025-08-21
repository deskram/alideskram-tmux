#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

custom_icon=$(get_tmux_option "@alideskram-custom-icon" "")

main() {
    echo "$custom_icon Hello alideskram"
}

main
