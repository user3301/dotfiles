{ config, pkgs, lib, username, dotfilesPath, ... }:

{
  # Import modular configurations
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./fonts.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then lib.mkDefault "/Users/${username}"
    else lib.mkDefault "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11";

  # Export ZSH path for shells and programs that expect $ZSH
  home.sessionVariables = {
    ZSH = "$HOME/.oh-my-zsh";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Provide ~/.oh-my-zsh by symlinking the oh-my-zsh package from the Nix store
  # (the package should already be present in `home.packages`).
  home.file.".oh-my-zsh" = {
    source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    # Let home-manager manage the whole directory
    recursive = true;
  };

  # Link zsh config files from the repo's `zsh/` directory into the home
  # `dotfilesPath` is provided by the flake via extraSpecialArgs.
  home.file.".zshrc" = {
    source = "${dotfilesPath}/zsh/.zshrc";
    # If you want to force overwrite without backups, set `force = true` here.
    recursive = false;
  };

  home.file.".zshenv" = {
    source = "${dotfilesPath}/zsh/.zshenv";
    recursive = false;
  };

  # Map XDG config directories from the repo into ~/.config
  xdg.configFile = {
    "wezterm" = {
      source = "${dotfilesPath}/wezterm/.config/wezterm";
      recursive = true;
    };
    "nvim" = {
      source = "${dotfilesPath}/nvim/.config/nvim";
      recursive = true;
    };
    "zellij" = {
      source = "${dotfilesPath}/zellij/.config/zellij";
      recursive = true;
    };
    "yazi" = {
      source = "${dotfilesPath}/yazi/.config/yazi";
      recursive = true;
    };
  };
}
