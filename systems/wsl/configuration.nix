{ pkgs, ... }:

{
  # Import WSL-specific configuration from nixos-wsl
  wsl = {
    enable = true;
    defaultUser = "user3301";
    startMenuLaunchers = true;

    # WSL-specific interoperability
    interop.register = true;

    # Use Windows SSH agent
    # wslConf.network.generateResolvConf = false;
  };

  # System configuration
  system.stateVersion = "25.05"; # Update to match your NixOS version

  # Nix settings
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Timezone (adjust to your preference)
  time.timeZone = "Australia/Melbourne";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";

  # User configuration
  users.users.user3301 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ]; # Enable sudo and docker
    shell = pkgs.zsh;
  };

  # Enable ZSH system-wide
  programs.zsh.enable = true;

  # Enable nix-ld for VS Code Remote and other dynamically linked executables
  programs.nix-ld = {
    enable = true;
  };

  # System packages (minimal, most packages go in Home Manager)
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    docker-compose
  ];

  # SSH configuration
  services.openssh = {
    enable = false; # Enable if you want SSH server
  };

  # Docker configuration for WSL2
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # WSL2-specific Docker daemon configuration
    daemon.settings = {
      # Use iptables for better WSL2 compatibility
      iptables = true;

      # Storage driver - overlay2 works well in WSL2
      storage-driver = "overlay2";

      # Default logging configuration
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

  # Systemd services specific to WSL
  # (Add any WSL-specific services here)
}
