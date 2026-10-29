#!/usr/bin/env bash
# Reload tmux colors after Noctalia regenerates ~/.config/tmux/colors.conf.
command -v tmux >/dev/null || exit 0
tmux has-session 2>/dev/null || exit 0      # no server running, nothing to do

tmux source-file "$HOME/.config/tmux/colors.conf"
# redraw every attached client now instead of waiting for status-interval
tmux list-clients -F '#{client_name}' | while read -r c; do
  tmux refresh-client -S -t "$c"
done
