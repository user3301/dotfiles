{ pkgs, ... }:

{
  # System configuration for macOS using nix-darwin

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
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (minimal, most packages go in Home Manager)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Programs
  programs.zsh.enable = true;

  system = {
    stateVersion = 4;

    # macOS system defaults
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "FiraCode"
      ];
    })
  ];

  # Services
  services.nix-daemon.enable = true;
}
