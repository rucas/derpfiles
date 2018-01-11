#!/bin/bash

SESSION="Hello?"

# if the session is already running, just attach to it.
tmux has-session -t "$SESSION"
if [ $? -eq 0 ]; then
  echo "Session $SESSION already exists. Attaching."
  sleep 1
  tmux -2 attach -t "$SESSION"
  exit 0;
fi

# create a new session, named $SESSION, and detach from it
tmux -2 new-session -d -s "$SESSION"

# Now populate the session with the windows you use every day
tmux set-option -g base-index 1
tmux set-window-option -t "$SESSION" -g automatic-rename off
tmux set-window-option -g pane-base-index 1

tmux new-window -t "$SESSION":0 -k -n code-
tmux split-window -h -p 10
tmux select-pane -t 2
tmux split-window -v -p 50
tmux select-pane -t 2
tmux split-window -v -p 50
tmux select-pane -t 4
tmux split-window -v -p 50
tmux new-window -t "$SESSION":1 -k -n dev-
tmux split-window -h -p 50
tmux select-pane -t 2
tmux split-window -v -p 50
tmux set-window-option -t "$SESSION":0 automatic-rename off

# all done. select starting window and get to work
tmux select-window -t "$SESSION":0
tmux -2 attach -t "$SESSION"
