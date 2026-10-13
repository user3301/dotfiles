# Helix

Run `hx` or `hx path/to/file` to open Helix. The shared
`helix/.config/helix/languages.toml` configures language servers while retaining
Helix's built-in syntax highlighting, keybindings, and editor defaults. Neovim
remains the default shell and Git editor.

## Languages

| Language | Language server | Required toolchain |
| --- | --- | --- |
| C# | `csharp-ls` | .NET SDK 10 or later |
| Go | `gopls` | Go |
| PowerShell | `powershell-editor-services` (stdio) | PowerShell 7 |
| Rust | `rust-analyzer` | Rust, Cargo, rustfmt |

The servers provide completion, diagnostics, navigation, and formatting.
Go and Rust retain Helix's built-in format-on-save setting; use `:format` for
manual formatting. Go uses only gopls, not the optional golangci-lint LSP.
Debug adapters are not installed by this setup, and PowerShell's stdio
connection does not provide an integrated console or debugging.

Open Helix from the solution or project directory so servers can discover
the workspace. Restore C# project dependencies with `dotnet restore` first.
C# uses csharp-ls rather than Neovim's Microsoft Roslyn server because the
locked Helix 25.07.1 release lacks the diagnostics support that server needs
(see [helix-editor/helix#15913](https://github.com/helix-editor/helix/issues/15913)).

## NixOS

`home/modules/helix.nix` installs the editor, csharp-ls, and PowerShell Editor
Services on both hosts and links the config from the checkout. It reuses
gopls, rust-analyzer, and rustfmt from `neovim.nix`, and the toolchains from
`languages.nix`. The PowerShell Editor Services launcher includes its own
PowerShell dependency, including on native NixOS.

After adding the package/module, rebuild the appropriate host (`make switch`
on WSL). Subsequent edits to the linked language configuration only require
restarting Helix.

## macOS and Arch Linux

The native manifests install Helix, and the default Stow selection links its
config. Install the language servers and toolchains separately. In particular,
csharp-ls can be installed with `dotnet tool install --global csharp-ls`; ensure
`~/.dotnet/tools` is on `PATH`.

For PowerShell, install PowerShell 7 and extract the
[PowerShell Editor Services release bundle](https://github.com/PowerShell/PowerShellEditorServices/releases).
If your package does not provide a `powershell-editor-services` launcher,
override its command in your project's `.helix/languages.toml`, using the
absolute path to the extracted script:

```toml
[language-server.powershell-editor-services]
command = "pwsh"
args = [
  "-NoLogo",
  "-NoProfile",
  "-File",
  "/absolute/path/PowerShellEditorServices/Start-EditorServices.ps1",
  "-Stdio",
  "-LogLevel",
  "Warning",
]
```

## Checking language support

```sh
hx --health c-sharp
hx --health go
hx --health powershell
hx --health rust
```

Each configured language server should be found on `PATH`. Missing optional
debug adapters or indent queries are separate from LSP support. For startup
errors, inspect `:log-open` inside Helix.
