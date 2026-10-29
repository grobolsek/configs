#!/usr/bin/env bash
set -euo pipefail

command -v nvim >/dev/null 2>&1 || exit 0

# Reload every running nvim instance that uses the noctalia theme, through its
# server socket. Instances on another theme are left alone.
reload='luaeval("pcall(function() if require(\"nvconfig\").base46.theme ~= \"noctalia\" then return end; package.loaded[\"themes.noctalia\"] = nil; require(\"base46\").load_all_highlights() end)")'
for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*.0; do
    [ -S "$sock" ] || continue
    timeout 3 nvim --server "$sock" --remote-expr "$reload" >/dev/null 2>&1 || true
done

# Recompile NvChad's base46 highlight cache last, so newly started nvim
# instances pick up the freshly rendered theme.
timeout 20 nvim --headless "+lua require('base46').load_all_highlights()" +qa >/dev/null 2>&1 || true
