# Neovim cheatsheet

Leader is `<Space>`. `<leader>ch` shows every mapping (NvChad's searchable list).

## Custom keymaps

| Keys | Mode | Action |
| --- | --- | --- |
| `;` | n | Enter command mode |
| `jk` | i | Escape |
| `<leader>cs` | n | Open this cheatsheet |
| `<C-h/j/k/l>` | n | Move between splits **and** tmux panes |
| `<C-\>` | n | Previous split / tmux pane |

## Debugging (DAP)

| Keys | Action |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle debug UI |

- Python / JS / TS: `<leader>dc` → "Launch current file" (or attach to a running process).
- Java: `<leader>dc` → a main class, or "Attach to JVM (port 5005)".
- Rust: `<leader>rd` → pick a binary or test.

## Rust (Rust files only)

| Keys | Action |
| --- | --- |
| `K` | Hover with actions |
| `<leader>ca` | Code action |
| `<leader>rr` / `<leader>rt` | Runnables / testables |
| `<leader>rd` | Debuggables |
| `<leader>re` | Explain error |
| `<leader>rc` | Open Cargo.toml |

## NvChad defaults worth remembering

| Keys | Action |
| --- | --- |
| `<C-n>` | Toggle file tree |
| `<leader>ff` / `<leader>fw` | Find files / live grep |
| `<leader>fb` | Find buffers |
| `<leader>fm` | Format file |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` | Close buffer |
| `<leader>/` | Toggle comment |
| `gd` / `gr` / `K` | Definition / references / hover |
| `<leader>ra` | LSP rename |
| `<leader>th` | Theme picker |

## Commands

| Command | Action |
| --- | --- |
| `:Trouble diagnostics` | Project diagnostics list |
| `:Obsession` | Start/stop recording a session |
| `:Mason` | Install LSP servers, formatters, debuggers |
| `:Lazy` | Manage plugins |
