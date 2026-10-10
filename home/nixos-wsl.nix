{ pkgs, ... }:

{
  # Shared modules (common.nix imports the rest)
  imports = [ ./modules/common.nix ];

  # During bootstrap there may be no active user session yet. Let the normal
  # WSL login start sockets and services instead of starting them during switch.
  systemd.user.startServices = "suggest";

  home = {
    # Platform-specific packages for WSL2
    packages = [ pkgs.powershell ];

    # Home Manager state version
    stateVersion = "25.05";
  };
}
