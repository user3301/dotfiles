{ pkgs, ... }:

{
  # Import common modules
  imports = [
    ./modules/common.nix
    ./modules/shell.nix
    ./modules/dev-tools.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/terminal.nix
    ./modules/languages.nix
  ];

  # During bootstrap there may be no active user session yet. Let the normal
  # WSL login start sockets and services instead of starting them during switch.
  systemd.user.startServices = "suggest";

  home = {
    # User information
    username = "user3301";
    homeDirectory = "/home/user3301";

    # Platform-specific packages for WSL2
    packages = with pkgs; [
      # WSL-specific tools
      powershell
    ];

    # WSL-specific session variables
    sessionVariables = {
      # Add any WSL-specific environment variables
    };

    # Home Manager state version
    stateVersion = "25.05";
  };
}
