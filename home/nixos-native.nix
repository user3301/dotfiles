{ pkgs, ... }:

{
  # Shared modules (common.nix imports the rest), plus native-only ones
  imports = [
    ./modules/common.nix
    ./modules/wezterm.nix
  ];

  home = {
    # GUI applications for native NixOS. gnupg comes from programs.gpg (git.nix)
    # and firefox is a system package (systems/native/configuration.nix).
    packages = [ pkgs.wezterm ];

    # Home Manager state version
    stateVersion = "25.11";
  };
}
