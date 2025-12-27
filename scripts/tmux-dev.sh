#!/bin/bash
SESSION="vaniabase"

cleanup() {
  tmux kill-session -t $SESSION 2>/dev/null
}

trap cleanup EXIT INT TERM HUP

tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  tmux new-session -d -s $SESSION
  tmux send-keys -t $SESSION:0.0 'pnpm dev' C-m
  tmux split-window -h -t $SESSION:0.0
  tmux send-keys -t $SESSION:0.1 'pnpm test' C-m
  tmux split-window -v -t $SESSION:0.1
  tmux select-pane -t $SESSION:0.0
fi

tmux attach-session -t $SESSION
