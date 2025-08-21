#!/bin/bash
current=$(tmux display-message -p '#S')
tmux list-sessions -F '#{session_name}' | grep -v "^$current$" | xargs -r -I{} tmux kill-session -t {}
