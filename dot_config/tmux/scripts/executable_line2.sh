#!/bin/sh
# Row 2 of the status bar: there only while tmux shows a message or a prompt.
#
# conf/theme.conf runs this from two #() jobs:
#   message-format    drawn for every message and prompt    → line2.sh show …
#   status-format[1]  drawn only when nothing covers row 2  → line2.sh hide …
#
# Arguments: show|hide SOCKET SESSION CLIENT_PID [TOKEN]
#   Prompts are drawn without a client, so for `show` CLIENT_PID can be empty.
#   TOKEN is unused; it changes on every show/hide so tmux re-runs the job for
#   each new message instead of reusing a cached result.
#
# `status` is a session option. When several clients share a session, row 2
# goes away only once every one of them has drawn it free. Each client records
# that in @line2_free_<pid> = the current @line2_shows; every new showing
# changes @line2_shows, which voids all of those records at once.

act=$1 sock=$2 sess=$3 pid=$4
[ -n "$sess" ] || exit 0
t() { tmux -S "$sock" "$@"; }
now() { date +%s%N; }

show() {
  info=$(t display -p -t "$sess" "#{status}|#{@line2_shows}|#{@line2_free_$pid}")
  st=${info%%|*}; rest=${info#*|}; tok=${rest%%|*}; mine=${rest#*|}
  if [ "$st" != 2 ]; then
    t set -t "$sess" status 2 \; set -t "$sess" @line2_shows "$(now)"
  elif [ -n "$pid" ] && [ "$mine" = "$tok" ]; then
    # row 2 is already up, and this client had drawn it free: busy again
    t set -t "$sess" @line2_shows "$(now)"
  fi
}

busy() {   # $1 = token: names of the other clients that have not drawn row 2 free
  opts=$(t show -t "$sess")
  printf '%s\n' "$clients" | while read -r p name; do
    [ "$p" = "$pid" ] && continue
    printf '%s\n' "$opts" | grep -qxF "@line2_free_$p $1" || printf '%s\n' "$name"
  done
}

hide() {
  info=$(t display -p -t "$sess" '#{status}|#{@line2_shows}')
  [ "${info%%|*}" = 2 ] || return 0
  tok=${info#*|}
  clients=$(t list-clients -t "$sess" -F '#{client_pid} #{client_name}')
  if [ "$(printf '%s\n' "$clients" | grep -c .)" -gt 1 ]; then
    t show -t "$sess" | grep -qxF "@line2_free_$pid $tok" ||
      t set -t "$sess" "@line2_free_$pid" "$tok"
    others=$(busy "$tok")
    if [ -n "$others" ]; then
      sleep 0.2                       # another client may be reporting right now
      others=$(busy "$tok")
    fi
    if [ -n "$others" ]; then
      # ask them to redraw: each one reports back here once row 2 is free for it
      for name in $others; do t refresh-client -S -t "$name"; done
      return 0
    fi
  fi
  t set -u -t "$sess" status \; set -t "$sess" @line2_hides "$(now)"
  # forget the per-client records (after the hide, so no client adds one back)
  for o in $(t show -t "$sess" | awk '$1 ~ /^@line2_free_/ { print $1 }'); do
    t set -u -t "$sess" "$o"
  done
}

case $act in
  show) show ;;
  hide) hide ;;
esac
exit 0
