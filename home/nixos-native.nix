{
  pkgs,
  ...
}:

{
  # Import common modules
  imports = [
    ./modules/common.nix
    ./modules/shell.nix
    ./modules/dev-tools.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/terminal.nix
    ./modules/editors.nix
    ./modules/languages.nix
    ./modules/desktop.nix
  ];

  # User information
  home.username = "user3301";
  home.homeDirectory = "/home/user3301";

  # Platform-specific packages for native NixOS
  home.packages = with pkgs; [
    gnupg
    # GUI applications
    wezterm
    firefox
    # Add more GUI apps as needed
  ];

  # Home Manager state version
  home.stateVersion = "25.11";
}
