{
  pkgs,
  user,
  ...
}:

{
  # Replace this VirtualBox configuration with the target machine's hardware config.
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
  system.stateVersion = "25.11"; # Compatibility defaults, not the package release

  # Extra groups for the user (wheel and the rest come from systems/common.nix)
  users.users.${user}.extraGroups = [
    "networkmanager"
    "video"
    "audio"
  ];

  # X11 and desktop environment
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;

    # Display manager
    displayManager = {
      # Choose your display manager
      lightdm.enable = true;
      defaultSession = "qtile";
      # Or use GDM:
      # gdm.enable = true;
    };

    # Desktop environment or window manager
    # Uncomment the one you want:
    # desktopManager.gnome.enable = true;
    # desktopManager.plasma5.enable = true;
    # windowManager.i3.enable = true;

    # Keyboard layout
    xkb.layout = "us";
  };

  # Fonts
  fonts.packages = with pkgs; [
    ubuntu-classic
  ];

  # System packages on top of systems/common.nix
  environment.systemPackages = with pkgs; [
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
