# Minimal bash configuration, kept as a portable fallback to zsh/.zshrc.
#
# Layout mirrors the zsh config: environment first (so non-interactive login
# shells get PATH too, the job zsh/.zshenv does), interactive-only setup after
# the guard. Login shells reach this file through ~/.bash_profile.

# ---------------------------------------------------------------------------
# Environment (mirrors zsh/.zshenv)
# ---------------------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
# This is required for asdf (0.16 or later)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# reorder PATH to make sure Nix's home-manager PATH comes before
# system path, so it uses nix installed package first
export PATH="$HOME/.nix-profile/bin:$PATH"

export CLOUDSDK_PYTHON=/usr/bin/python3

# GPG TTY for commit signing. `tty` writes "not a tty" to stdout and fails when
# stdin is not a terminal, so assign only on success and keep any inherited value.
if __tty=$(tty 2>/dev/null); then
  export GPG_TTY="$__tty"
fi
unset __tty

# Home Manager session variables, when this machine is managed by Nix.
# The first file sourced sets a guard, so the second is a no-op.
for __hm_vars in \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" \
  "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"; do
  [ -r "$__hm_vars" ] && . "$__hm_vars"
done
unset __hm_vars

# ---------------------------------------------------------------------------
# Interactive shells only
# ---------------------------------------------------------------------------
case $- in
  *i*) ;;
  *) return ;;
esac

# History. mcfly bails out with an error unless the file already exists, so
# create it here rather than waiting for the first shell to exit.
HISTFILE="${HISTFILE:-$HOME/.bash_history}"
[ -e "$HISTFILE" ] || (umask 077 && : > "$HISTFILE")
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history"
HISTTIMEFORMAT="%F %T "
shopt -s histappend cmdhist

# Shell behaviour (options unknown to bash 3.2 are skipped quietly)
shopt -s checkwinsize globstar autocd cdspell dirspell no_empty_cmd_completion 2>/dev/null

# vi keybindings, matching the zsh vi-mode plugin
set -o vi
# Keys bash leaves unbound in vi-insert but zsh's viins keymap provides
bind -m vi-insert '"\C-l": clear-screen' 2>/dev/null
bind -m vi-insert '"\C-a": beginning-of-line' 2>/dev/null
bind -m vi-insert '"\C-e": end-of-line' 2>/dev/null
bind -m vi-insert '"\C-k": kill-line' 2>/dev/null
# Open the current buffer line in $EDITOR, as ^x^e does in zsh
bind -m vi-insert '"\C-x\C-e": edit-and-execute-command' 2>/dev/null

# bash-completion (Nix profile, system, or Homebrew)
for __bc in \
  "$HOME/.nix-profile/share/bash-completion/bash_completion" \
  "/etc/profiles/per-user/$USER/share/bash-completion/bash_completion" \
  /usr/share/bash-completion/bash_completion \
  /opt/homebrew/etc/profile.d/bash_completion.sh \
  /usr/local/etc/profile.d/bash_completion.sh; do
  if [ -r "$__bc" ]; then
    . "$__bc"
    break
  fi
done
unset __bc

# Prompt: user@host:cwd (git-branch)
__bash_git_branch() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 0
  printf ' (%s)' "$branch"
}
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__bash_git_branch)\[\e[0m\]\$ '

# General aliases
alias v="nvim"

# eza as default lister
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l  --group-directories-first --icons=auto --git'
  alias la='eza -la --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi

# Load local-specific configuration if it exists. Deliberately before the two
# integrations below: on bash < 5.1 (macOS /bin/bash is 3.2) PROMPT_COMMAND is a
# plain string, so a bare assignment here would wipe their hooks. Both append to
# whatever it leaves behind, and it can still set MCFLY_*/_ZO_* to configure them.
[ -f "$DOTFILES/bash/.bashrc.local" ] && . "$DOTFILES/bash/.bashrc.local"

# zoxide: smarter cd, provides `z` and `zi`
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# mcfly: fuzzy ^R history search (after zoxide, so it wraps that prompt hook)
command -v mcfly >/dev/null 2>&1 && eval "$(mcfly init bash)"
