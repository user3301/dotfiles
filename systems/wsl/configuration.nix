{ pkgs, user, ... }:

{
  wsl = {
    enable = true;
    defaultUser = user;
    startMenuLaunchers = true;

    # Leave interop.register off: WSL 3 registers the .exe handler itself and
    # locks binfmt_misc/status, which makes systemd-binfmt fail on every switch.
  };

  # System configuration
  system.stateVersion = "25.05"; # Compatibility defaults, not the package release

  # Docker access for the user (wheel and the rest come from systems/common.nix)
  users.users.${user}.extraGroups = [ "docker" ];

  # Enable nix-ld for VS Code Remote and other dynamically linked executables
  programs.nix-ld.enable = true;

  # System packages on top of systems/common.nix
  environment.systemPackages = [ pkgs.docker-compose ];

  # Docker configuration for WSL2
  virtualisation.docker = {
    enable = true;

    # WSL2-specific Docker daemon configuration
    daemon.settings = {
      # Use iptables for better WSL2 compatibility
      iptables = true;

      # Storage driver - overlay2 works well in WSL2
      storage-driver = "overlay2";

      # Rotated json-file logs instead of the NixOS default (journald)
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };

    # Auto-prune configuration to save disk space
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };
}
