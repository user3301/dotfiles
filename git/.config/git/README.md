# Git Configuration

`config` is shared by NixOS (Home Manager symlink) and macOS/Arch Linux (GNU
Stow). It sets Neovim as the editor, delta as the pager/diff filter, `input`
line-ending conversion, `zdiff3` merge conflicts, and SSH commit signing.
Install Neovim and delta when using it outside NixOS.

The tracked identity is a default. Set your own identity and signing key in
`~/.config/git/config.local`, which is already included **after** the defaults:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
    signingkey = ~/.ssh/id_ed25519.pub
```

Use an existing SSH signing key or generate one separately; no private keys are
provided. `commit.gpgsign = true` is enabled, so commits require a usable signing
key and private-key/agent access. If signing is not wanted on this machine,
override it explicitly:

```gitconfig
[commit]
    gpgsign = false
```

`git/.config/git/config.local` is ignored by the repository. When the whole
config directory is symlinked, creating the local file writes into the checkout;
keep it untracked. An existing `~/.gitconfig` can override XDG config settings.
Inspect the source of effective settings with:

```sh
git config --show-origin --list
```

There are no automatic OS-specific includes. Only `config.local` is included.
If you add more include paths yourself, Git reads all existing files at those
paths; names such as `config.darwin` do not cause OS detection.

`core.excludesfile` points to `.gitignore_global`. The sibling `ignore` file is
not the explicitly selected global ignore file. Lazygit's separate config
also uses delta, with `--paging=never` because Lazygit handles scrolling itself.
