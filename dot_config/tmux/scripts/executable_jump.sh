#!/usr/bin/env bash
# prefix w: session / window / pane switcher (replaces tmux's choose-tree).
#
#   Enter   switch            Tab     mark (several)       Ctrl-t  tmux's own tree
#   Ctrl-x  kill (marked)     Alt-m   move marked here     Esc     close
#           (onto a window: marked panes join it; onto a session: they become windows)
#   Ctrl-r  rename            Alt-↑↓  reorder window
#   Ctrl-n  new session
#
# Rows carry a tmux target in a hidden first field: =sess:  =sess:win  =sess:win.pane
self=$(realpath "$0")
dir=$(dirname "$self")
. "$dir/lib/ui.sh"

list() {   # $1 = current "sess:win", marked with ●. One tmux call for the whole tree.
  tmux list-panes -a -F "#{session_name}	#{session_windows}	#{session_attached}	#{window_index}	#{window_name}	#{window_panes}	#{pane_active}	#{s|^$HOME|~|:pane_current_path}	#{pane_index}	#{pane_current_command}" |
  awk -F'\t' -v cur="$1" -v A="$A" -v B="$B" -v D="$D" -v R="$R" '
    function flush() {         # window row (path = its active pane), then its panes
      if (w == "") return
      printf "=%s\t    %s%s%s %s  %s%s%s%s\n", w, A, wi, R, wn, D, wpath, R, (w == cur ? " " A "●" R : "")
      printf "%s", panes; panes = ""
    }
    ($1 ":" $4) != w {
      flush()
      if (($1 "") != s) {      # "" forces a string compare (session "0" vs unset)
        s = $1
        printf "=%s:\t%s%s%s  %s%s win%s%s\n", s, A B, s, R, D, $2, ($3 > 0 ? " · attached" : ""), R
      }
      w = $1 ":" $4; wi = $4; wn = $5
    }
    $7 == 1 { wpath = $8 }
    $6 > 1  { panes = panes sprintf("=%s.%s\t        %s└ %s%s %s\n", w, $9, D, $9, R, $10) }
    END { flush() }'
}

pos() {    # line number of target $1 in the list (for fzf's pos action)
  list "$CUR" | cut -f1 | grep -nxF -- "$1" | cut -d: -f1 | head -1
}

kind() {   # session | window | pane
  case $1 in *:) echo session ;; *:*.*) echo pane ;; *) echo window ;; esac
}

session_of() { local t=${1#=}; echo "${t%%:*}"; }

id_of() {  # stable tmux id ($session, @window, %pane) for a row target
  case $(kind "$1") in
    session) tmux display -p -t "$1" '#{session_id}' ;;
    window)  tmux display -p -t "$1" '#{window_id}' ;;
    pane)    tmux display -p -t "$1" '#{pane_id}' ;;
  esac
}

case $1 in
  --list) list "$2"; exit ;;

  --kill)   # kill every marked target (panes first, sessions last)
    shift
    # resolve to permanent ids first: renumber-windows shifts indexes after each kill
    ids=(); for t in "$@"; do ids+=("$(kind "$t") $(id_of "$t")"); done
    for k in pane window session; do
      for e in "${ids[@]}"; do [ "${e%% *}" = $k ] && tmux "kill-$k" -t "${e#* }" 2>/dev/null; done
    done
    exit ;;

  --move)   # $2 = highlighted row (destination), $3 = current, rest = marked rows
    # Highlighted a session: marked windows move there, marked panes become
    # windows there. Highlighted a window (or one of its panes): marked panes
    # join that window, marked windows move to its session.
    to=$2; shift 3
    dsess=$(tmux display -p -t "$to" '#{session_id}')
    dwin=""; [ "$(kind "$to")" = session ] || dwin=$(tmux display -p -t "$to" '#{window_id}')
    todo=()   # "kind id source-session", resolved to ids before anything moves
    for t in "$@"; do
      k=$(kind "$t"); s=$(tmux display -p -t "$t" '#{session_id}')
      case $k in
        session) continue ;;
        pane) if [ -n "$dwin" ]; then
                [ "$(tmux display -p -t "$t" '#{window_id}')" = "$dwin" ] && continue
              else
                [ "$s" = "$dsess" ] && continue
              fi ;;
        window) [ "$s" = "$dsess" ] && continue ;;
      esac
      todo+=("$k $(id_of "$t") $s")
    done
    for e in "${todo[@]}"; do
      read -r k id src <<<"$e"
      case $k in
        window) tmux move-window -d -s "$id" -t "$dsess:" ;;
        pane) if [ -n "$dwin" ]; then tmux join-pane -d -h -s "$id" -t "$dwin"
              else tmux break-pane -d -s "$id" -t "$dsess:"; fi ;;
      esac
      tmux move-window -r -t "$src" 2>/dev/null   # close the numbering gap
    done
    # indexes may have shifted: find the current window and the destination again
    CUR=$(tmux display -p -c "$(ui_client)" '#{session_name}:#{window_index}')
    if [ -n "$dwin" ]; then dest="=$(tmux display -p -t "$dwin" '#{session_name}:#{window_index}')"
    else dest="=$(tmux display -p -t "$dsess" '#{session_name}'):"; fi
    echo "clear-selection+reload-sync($self --list $(printf %q "$CUR"))+pos($(pos "$dest"))"
    exit ;;

  --swap)   # $2 = window row, $3 = -1 | +1, $4 = current
    t=$2; CUR=$4
    [ "$(kind "$t")" = window ] || exit 0
    s=$(session_of "$t"); i=${t##*:}
    mapfile -t idx < <(tmux list-windows -t "=$s:" -F '#{window_index}')
    for n in "${!idx[@]}"; do [ "${idx[$n]}" = "$i" ] && break; done
    m=$((n + $3)); [ $m -lt 0 ] || [ $m -ge ${#idx[@]} ] && exit 0
    j=${idx[$m]}
    tmux swap-window -d -s "=$s:$i" -t "=$s:$j"
    [ "$CUR" = "$s:$i" ] && CUR="$s:$j" || { [ "$CUR" = "$s:$j" ] && CUR="$s:$i"; }
    echo "reload-sync($self --list $(printf %q "$CUR"))+pos($(pos "=$s:$j"))"
    exit ;;
esac

client=$(ui_client)
CUR=$(tmux display -p -c "$client" '#{session_name}:#{window_index}')
start=$(pos "=$CUR"); start=${start:-1}
Q=$(printf %q "$CUR")

out=$(list "$CUR" | ui_fzf --delimiter='\t' --with-nth=2 --no-sort --multi \
  --expect=ctrl-n,ctrl-r,ctrl-t \
  --header="$(ui_hint '↵' switch C-x kill C-r rename C-n new)
$(ui_hint Tab mark M-m move 'M-↑↓' order C-t tree)" \
  --preview="python3 -I $dir/preview.py {1}" --preview-window='right,62%,border-left,nowrap,noinfo' \
  --bind="load:pos($start)+unbind(load)" \
  --bind="ctrl-x:execute-silent($self --kill {+1})+clear-selection+reload($self --list $Q)" \
  --bind="alt-m:transform($self --move {1} $Q {+1})" \
  --bind="alt-up:transform($self --swap {1} -1 $Q)" \
  --bind="alt-down:transform($self --swap {1} +1 $Q)") || exit 0

key=$(sed -n 1p <<<"$out"); target=$(sed -n 2p <<<"$out" | cut -f1)
case $key in
  # templates target ids, never names, so quotes in names can't break them
  ctrl-n) ui_prompt 'new session:' '' "new-session -s %1" ;;
  ctrl-t) ui_later "choose-tree -Zs" ;;
  ctrl-r)
    case $(kind "$target") in
      session) ui_prompt 'rename session:' "$(session_of "$target")" "rename-session -t '$(id_of "$target")' -- %1" ;;
      window)  ui_prompt 'rename window:' "$(tmux display -p -t "$target" '#W')" "rename-window -t '$(id_of "$target")' -- %1" ;;
      # @win.idx, not %pane: a %N in the template would be read as an argument
      pane)    ui_prompt 'pane title:' "$(tmux display -p -t "$target" '#T')" \
                 "select-pane -t '$(tmux display -p -t "$target" '#{window_id}.#{pane_index}')' -T %1" ;;
    esac ;;
  *) [ -n "$target" ] && tmux switch-client -c "$client" -t "$target" ;;
esac
