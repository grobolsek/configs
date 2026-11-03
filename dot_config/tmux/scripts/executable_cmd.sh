#!/usr/bin/env bash
# prefix :  tmux command palette with live suggestions.
#   Enter      on a suggestion: open the ':' line prefilled, add arguments
#   Enter      after typing arguments (a space) or with no match: run it
#   Alt-Enter  run the highlighted command with no arguments
. "$(dirname "$0")/lib/ui.sh"

out=$(tmux list-commands | awk -v A="$A" -v D="$D" -v R="$R" '{
    name=$1; rest=substr($0, length($1)+2); alias=""
    if (rest ~ /^\(/) { alias=substr(rest,1,index(rest,")")); rest=substr(rest,length(alias)+2) }
    printf "%s\t%s%-22s%s %s%-13s%s %s\n", name, A, name, R, D, alias, R, rest }' |
  ui_fzf --delimiter='\t' --with-nth=2 --nth=1 --print-query --expect=alt-enter \
    --prompt=': ' \
    --header="$(ui_hint '↵' 'add args' 'args ↵' run 'M-↵' 'run as-is' Esc close)")
rc=$?; [ $rc -eq 130 ] && exit 0
query=$(sed -n 1p <<<"$out"); key=$(sed -n 2p <<<"$out"); name=$(sed -n 3p <<<"$out" | cut -f1)

if [[ -n $query && ( $query == *" "* || -z $name ) ]]; then
  ui_later "$query"                         # typed a full command
elif [[ $key == alt-enter && -n $name ]]; then
  ui_later "$name"
elif [[ -n $name ]]; then
  ui_prompt '' "$name "                     # ':' line prefilled, add arguments
fi
