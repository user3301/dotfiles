# Neovim Configuration

This is a customized [LazyVim](https://www.lazyvim.org/) configuration, not an
unmodified starter. `init.lua` loads `lua/config/lazy.lua`, which bootstraps
lazy.nvim using Git and imports LazyVim plus `lua/plugins/`.

NixOS links this directory through Home Manager. On macOS and Arch Linux,
install Neovim and its dependencies with the native package manager, then run
`stow --target="$HOME" nvim` from `~/dotfiles`. Stow does not install Neovim.

## Plugins and UI

`lazyvim.json` enables Copilot Chat, mini-surround, debugging and testing
support, and .NET, Go, and Python extras. Additional plugin configuration
selects Catppuccin Frappe, customizes Markdown rendering and the Snacks
dashboard/picker, and adds smear-cursor and Roslyn support. Relative line
numbers are disabled; folding uses Tree-sitter.

Plugins are installed by lazy.nvim on first launch and pinned separately in
`lazy-lock.json`. Network access and Git are needed for installation. Use
`:Lazy` to manage plugins and `:checkhealth` to diagnose missing dependencies.
Review lockfile changes after plugin updates. Copilot authentication is a
separate manual step.

## Language servers

`lua/plugins/lsp.lua` detects NixOS via `/etc/NIXOS` or `/etc/nixos`.
For the explicitly configured Lua, TypeScript/web, Python (Pyright), Rust, and
Go servers, Mason management is disabled on NixOS and enabled elsewhere.
NixOS installs servers, formatters, compiler tools, and fswatch through
`home/modules/neovim.nix`.

The Nix server `nil` always has Mason management disabled; provide it on `PATH`
yourself outside NixOS if you edit Nix files. Native package manifests do not
install all language runtimes, servers, or formatters. Mason-managed tools may
also need Node.js, Python, Go, or other runtime/build dependencies.

For C#, OmniSharp is disabled in favor of `seblyng/roslyn.nvim`. On NixOS,
`roslyn-ls` supplies `Microsoft.CodeAnalysis.LanguageServer` on `PATH`.
Elsewhere, the additional Crashdummyy Mason registry allows:

```vim
:MasonInstall roslyn
```

Roslyn enables Neovim file watching; install `fswatch` outside NixOS as needed.
The C# formatter override clears CSharpier so LSP formatting can be used.

Python configuration looks for `venv`, `.venv`, and `.virtualenv`: Pyright uses
a discovered Python interpreter, while pylsp can use a virtualenv's `pylsp`
executable. Its Ruff plugin settings require that plugin to be installed in
the chosen environment.

See [LazyVim's installation requirements](https://www.lazyvim.org/installation)
for current Neovim, compiler, and external-tool requirements.
