# shellcheck shell=bash
# Shared look + helpers for every fzf helper popup (keys.sh, cmd.sh, jump.sh).
# Source it:   . "$(dirname "$0")/lib/ui.sh"
#
# Change the look here once and every helper follows. The popup frame (border,
# title, size) comes from the `helper` alias in conf/ui.conf, and the colors are
# read live from tmux (@bar, @c_accent, …), so Noctalia theme changes apply.
#
#   ui_fzf [fzf args…]        fzf with the shared style; your args override it
#   ui_hint key word …        header like the status-bar hints: "↵ run · Esc close"
#   ui_client                 the client that opened the popup
#   ui_later 'tmux cmds'      run tmux commands after the popup has closed
#   ui_prompt label text [template]   open a prompt (it lands on row 2)
#   $A $D $B $R               ANSI: accent, dim, bold, reset, for list text

IFS=$'\t' read -r C_BAR C_SEG C_FG C_DIM C_DARK C_ACC < <(
  tmux display -p '#{@bar}	#{@seg2}	#{@fg}	#{@dim}	#{@dark}	#{@c_accent}')

_ui_rgb() { printf '\e[38;2;%d;%d;%dm' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
A=$(_ui_rgb "$C_ACC"); D=$(_ui_rgb "$C_DIM"); B=$'\e[1m'; R=$'\e[0m'

# Selected row = accent background + dark bold text, exactly like the
# prefix Space menu (menu-selected-style). `strip` drops the list's own ANSI
# colors on that row so nothing disappears into the accent background.
ui_fzf() {
  fzf --ansi --layout=reverse --border=none --padding=0,1 \
    --info=inline-right --no-scrollbar --header-first \
    --prompt='  ' --pointer=' ' --gutter=' ' --highlight-line \
    --preview-window='right,55%,border-left,nowrap' \
    --color="bg:$C_BAR,fg:$C_FG,hl:$C_ACC:bold,gutter:$C_BAR" \
    --color="bg+:$C_ACC,fg+:$C_DARK:bold:strip,hl+:$C_DARK:bold:underline,pointer:$C_DARK" \
    --color="prompt:$C_ACC,query:$C_FG,info:$C_DIM,header:$C_DIM,separator:$C_SEG" \
    --color="border:$C_SEG,preview-bg:$C_BAR" \
    "$@"
}

ui_hint() {
  local out="" sep=""
  while [ $# -ge 2 ]; do out+="$sep$A$1$R $D$2$R"; sep="$D · $R"; shift 2; done
  printf '%s' "$out"
}

# The `helper` alias (conf/ui.conf) stores the opening client in @popup_client,
# because a popup can't see it otherwise. Fallback: most recently active client.
ui_client() {
  local c; c=$(tmux show -gqv @popup_client)
  if [ -n "$c" ] && tmux list-clients -F '#{client_name}' | grep -qxF -- "$c"; then
    printf '%s' "$c"
  else
    tmux list-clients -F '#{client_activity} #{client_name}' | sort -rn | head -1 | cut -d' ' -f2
  fi
}

ui_later() { tmux run-shell -b -d 0.1 -C "$1"; }

# Template uses %1 for the typed text (not %%, which mangles single quotes).
ui_prompt() {
  local c tpl="" text=$2; c=$(ui_client)
  [ -n "$3" ] && tpl="{ $3 }"                  # no template = run what was typed
  # -I text goes through run -C and command-prompt, so escape it for both
  text=${text//\\/\\\\}; text=${text//\"/\\\"}; text=${text//\$/\\\$}; text=${text//#/####}
  ui_later "command-prompt -t '$c' -p '$1' -I \"$text\" $tpl"
}
