# Neovim Configuration

This is a customized [LazyVim](https://www.lazyvim.org/) configuration, not an
unmodified starter. `init.lua` loads `lua/config/lazy.lua`, which bootstraps
lazy.nvim using Git and imports LazyVim plus `lua/plugins/`.

NixOS links this directory through Home Manager. On macOS and Arch Linux,
install Neovim and its dependencies with the native package manager, then run
`stow --target="$HOME" nvim` from `~/dotfiles`. Stow does not install Neovim.

## Plugins and UI

`lazyvim.json` enables Copilot Chat, mini-surround, debugging and testing
support, and Go and Python extras. Additional plugin configuration
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
NixOS installs servers, formatters, Tree-sitter, and inotify-tools through
`home/modules/neovim.nix`; Neovim itself is a system package, and ripgrep, fd,
and gcc come from `home/modules/dev-tools.nix`.

The Nix server `nil` always has Mason management disabled; provide it on `PATH`
yourself outside NixOS if you edit Nix files. Native package manifests do not
install all language runtimes, servers, or formatters. Mason-managed tools may
also need Node.js, Python, Go, or other runtime/build dependencies.

For C#, `lua/plugins/roslyn.lua` configures `seblyng/roslyn.nvim` with
`opts = {}` and explicitly installs the `c_sharp` Tree-sitter parser. The
LazyVim `lang.dotnet` extra is disabled: OmniSharp, CSharpier, and .NET-specific
test/debug adapters are not configured. C# formatting uses Roslyn's LSP
formatting through LazyVim's normal fallback.

The pinned plugin requires Neovim >= 0.12 and Roslyn >=
`5.12.0-1.26453.19`. On NixOS, `roslynOverlay` in `flake.nix` supplies
`roslyn-ls` 5.12.0-1.26475.2, while `home/modules/languages.nix` supplies the
.NET 10 SDK. Projects with a `global.json` may require additional SDKs.
See [version pinning](../../../docs/EXAMPLE-VERSION-PINNING.md) for the server
recipe and its writable-cache patch.

Two small adaptations remain instead of additional language-server settings:
the Nix-provided `Microsoft.CodeAnalysis.LanguageServer` is started directly
with `--stdio` (it is not the thin client that accepts `--daemon-mode`), and
Neovim's file-watching capability is enabled to avoid the .NET watcher that
previously crashed. Neovim 0.12 uses `inotifywait` from `inotify-tools` on
Linux, not `fswatch`; Nix supplies it, and Arch users should install it with
pacman. macOS uses Neovim's native watcher. File-watching behavior otherwise
uses the plugin's default `auto`.

Roslyn also probes `/usr/lib/dotnet/packs` and `/usr/share/dotnet/packs`.
Neovim can report non-fatal watch warnings for these missing conventional
paths on NixOS; the actual Nix SDK and project paths are watched separately.

Outside NixOS, the additional Crashdummyy Mason registry allows:

```vim
:MasonInstall roslyn
```

Install a server version compatible with the plugin. On NixOS, apply the Nix
configuration before restarting Neovim after a server pin change; the Lua
files are linked directly, but package upgrades require a rebuild.

Python configuration looks for `venv`, `.venv`, and `.virtualenv`: Pyright uses
a discovered Python interpreter, while pylsp can use a virtualenv's `pylsp`
executable. Its Ruff plugin settings require that plugin to be installed in
the chosen environment.

See [LazyVim's installation requirements](https://www.lazyvim.org/installation)
for current Neovim, compiler, and external-tool requirements.
