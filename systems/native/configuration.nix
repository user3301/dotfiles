{
  pkgs,
  ...
}:

{
  # Import hardware configuration (will be generated on the target machine)
  imports = [ ../hardware/hardware-vb.nix ];

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "nixos"; # Change to your hostname
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };

  # System configuration
  system.stateVersion = "25.11"; # Update to match your NixOS version

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
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
  };

  # Enable ZSH system-wide
  programs.zsh.enable = true;

  # X11 and desktop environment
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;

    # Display manager
    displayManager.lightdm.enable = true;

    # Keyboard layout
    xkb.layout = "us";
  };

  # Default session
  services.displayManager.defaultSession = "none+i3";

  # Fonts
  fonts.packages = with pkgs; [
    ubuntu-classic
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # System packages (minimal, most packages go in Home Manager)
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    firefox # Or your preferred browser
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Printing support (optional)
  # services.printing.enable = true;

  # Graphics drivers (adjust based on your hardware)
  # hardware.opengl.enable = true;
  # For NVIDIA:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.modesetting.enable = true;
}
