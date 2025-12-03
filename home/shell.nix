{ config, pkgs, lib, ... }:

{
  # Shell configuration (zsh, bash, etc.)
  # Currently using existing zsh config from zsh/.zshrc via GNU Stow

  # Future: Migrate zsh configuration to home-manager
  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   autosuggestion.enable = true;
  #   syntaxHighlighting.enable = true;
  #
  #   oh-my-zsh = {
  #     enable = true;
  #     theme = "mikeh";
  #     plugins = [
  #       "git"
  #       "z"
  #       "colored-man-pages"
  #       "asdf"
  #       "vi-mode"
  #     ];
  #   };
  #
  #   shellAliases = {
  #     # Your aliases here
  #   };
  #
  #   initExtra = ''
  #     # Additional shell configuration
  #     export EDITOR="nvim"
  #
  #     # mcfly
  #     command -v mcfly &> /dev/null && eval "$(mcfly init zsh)"
  #
  #     # atuin
  #     command -v atuin &> /dev/null && . "$HOME/.atuin/bin/env"
  #     command -v atuin &> /dev/null && eval "$(atuin init zsh)"
  #
  #     # yazi shell wrapper
  #     function y() {
  #       local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  #       yazi "$@" --cwd-file="$tmp"
  #       IFS= read -r -d '' cwd < "$tmp"
  #       [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  #       rm -f -- "$tmp"
  #     }
  #   '';
  # };

  # Future: Other shell tools
  # programs.bash.enable = true;
  # programs.fish.enable = true;
  # programs.starship.enable = true;  # Modern prompt
  # programs.direnv.enable = true;    # Per-directory environments
}
