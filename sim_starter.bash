#!/bin/bash

# Define session name and commands for each pane
SESSION_NAME="my_session"
COMMAND1="htop"
COMMAND2="tail -f /var/log/syslog"
COMMAND3="watch -n 1 date"

# Create a new detached tmux session with the first command running in the initial pane
tmux new-session -d -s "$SESSION_NAME" "$COMMAND1"

# Split the first pane horizontally and run the second command in the new pane
tmux split-window -h -t "$SESSION_NAME":0.0 "$COMMAND2"

# Split the newly created pane vertically and run the third command
tmux split-window -v -t "$SESSION_NAME":0.1 "$COMMAND3"

# Optional: select the first pane (or any other pane you want to focus on)
tmux select-pane -t "$SESSION_NAME":0.0

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
