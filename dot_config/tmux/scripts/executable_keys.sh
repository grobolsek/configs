#!/usr/bin/env bash
# prefix ?: searchable list of every keybinding. Enter runs the selected one.
. "$(dirname "$0")/lib/ui.sh"
prefix=$(tmux show -gv prefix)

entries() {   # $1 = table; prints "key<TAB>description" (list-keys puts the prefix in front of both tables)
  local l key desc args=(-N -T "$1"); [ "$1" = prefix ] && args=(-a "${args[@]}")
  tmux list-keys "${args[@]}" | while IFS= read -r l; do
    l=${l#"$prefix" }; key=${l%% *}; desc=${l#"$key"}; desc=${desc#"${desc%%[! ]*}"}
    printf '%s\t%s\n' "$key" "$desc"
  done
}

list() {
  # prefix table: every binding (note, or the command when it has none)
  entries prefix | while IFS=$'\t' read -r key desc; do
    printf 'prefix\t%s\t%s%-9s%s %s\n' "$key" "$A" "$key" "$R" "$desc"
  done
  # root table (no prefix): only bindings with a note
  entries root | while IFS=$'\t' read -r key desc; do
    printf 'root\t%s\t%s%-9s%s %s %s(no prefix)%s\n' "$key" "$A" "$key" "$R" "$desc" "$D" "$R"
  done
}

sel=$(list | ui_fzf --delimiter='\t' --with-nth=3 \
  --header="$(ui_hint '↵' run Esc close prefix "$prefix")") || exit 0

table=$(cut -f1 <<<"$sel"); key=$(cut -f2 <<<"$sel")
keys=$(printf '%q ' "$key"); [ "$table" = prefix ] && keys="$(printf '%q ' "$prefix")$keys"
# press the keys for real once the popup is gone
ui_later "send-keys -K -c '$(ui_client)' -- $keys"
