{ config, pkgs, dotfilesPath, system, username, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  home = {
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

    stateVersion = "24.05";

    packages = with pkgs; [
      # Shell & terminal
      zsh
      fzf
      mcfly

      # Editors & dev tools
      neovim
      helix

      # Terminal multiplexers & utilities
      wezterm
      zellij

      # File utilities
      bat
      ripgrep
      fd
      yazi

      # Dev tools
      jq
      lazygit

      # Fonts - Using Nerd Fonts for better compatibility
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ] ++ pkgs.lib.optionals isDarwin [
      # macOS specific packages
    ];

    # Session variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # Link dotfiles configurations
  xdg.configHome = "${config.home.homeDirectory}/.config";

  # Wezterm configuration
  xdg.configFile."wezterm" = {
    source = "${dotfilesPath}/wezterm/.config/wezterm";
    recursive = true;
  };

  # Neovim configuration
  # Note: LazyVim and lazy.nvim will be automatically bootstrapped on first run
  # The bootstrap is handled by lua/config/lazy.lua
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Additional packages that LazyVim plugins might need
    extraPackages = with pkgs; [
      # LSP servers, formatters, linters can be added here
      # or managed by Mason within neovim
      ripgrep  # Required for Telescope live_grep
      fd       # Required for Telescope find_files
      git      # Required for various plugins
    ];
  };

  # Link the neovim config directory
  xdg.configFile."nvim" = {
    source = "${dotfilesPath}/nvim/.config/nvim";
    recursive = true;
  };

  # Helix configuration
  xdg.configFile."helix" = {
    source = "${dotfilesPath}/helix/.config/helix";
    recursive = true;
  };

  # Zellij configuration
  xdg.configFile."zellij" = {
    source = "${dotfilesPath}/zellij/.config/zellij";
    recursive = true;
  };

  # Yazi configuration
  xdg.configFile."yazi" = {
    source = "${dotfilesPath}/yazi/.config/yazi";
    recursive = true;
  };

  # Zsh configuration with oh-my-zsh
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    # Enable oh-my-zsh
    oh-my-zsh = {
      enable = true;
      theme = "mikeh";
      plugins = [
        "git"
        "z"
        "colored-man-pages"
        "asdf"
        "vi-mode"
      ];
    };

    # Environment variables (loaded early)
    envExtra = ''
      # General environment variables
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/go/bin:$PATH"
      export CLOUDSDK_PYTHON=/usr/bin/python3

      # This is required for asdf (0.16 or later)
      export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

      # Load local-specific configuration if it exists
      [[ -f ${dotfilesPath}/zsh/.zshenv.local ]] && source ${dotfilesPath}/zsh/.zshenv.local
    '';

    # Additional initialization (loaded after oh-my-zsh)
    initExtra = ''
      # Mcfly integration
      command -v mcfly &> /dev/null && eval "$(mcfly init zsh)"

      # Atuin integration
      command -v atuin &> /dev/null && . "$HOME/.atuin/bin/env"
      command -v atuin &> /dev/null && eval "$(atuin init zsh)"

      # "y" shell wrapper for Yazi that changes the current working directory when exiting Yazi
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d ''' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }

      # SDKMAN - THIS MUST BE AT THE END
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    '';

    # Shell aliases
    shellAliases = {
      vim = "nvim";
      v = "nvim";
    };
  };

  # Aerospace configuration (macOS window manager)
  xdg.configFile."aerospace" = {
    source = "${dotfilesPath}/aerospace/.config/aerospace";
    recursive = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
  };

  # Bat (cat replacement)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # FZF (fuzzy finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Ripgrep
  programs.ripgrep = {
    enable = true;
  };

  # Home manager configuration
  programs.home-manager.enable = true;
}
