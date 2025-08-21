#!/bin/bash
# Keep only the last 10 tmux-resurrect sessions
RES_DIR="$HOME/.local/share/tmux/resurrect"
MAX_SESSIONS=10

cd "$RES_DIR" || exit

# List files sorted by modification time
FILES=($(ls -t | grep '^tmux_resurrect_'))
COUNT=${#FILES[@]}

# Delete older files if more than MAX_SESSIONS
if [ $COUNT -gt $MAX_SESSIONS ]; then
  for f in "${FILES[@]:$MAX_SESSIONS}"; do
    rm -f "$f"
  done
fi
