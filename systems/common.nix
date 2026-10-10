{ pkgs, user, ... }:

{
  # Settings shared by every NixOS host

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

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable sudo
    shell = pkgs.zsh;
  };

  # Enable ZSH system-wide
  programs.zsh.enable = true;

  # System packages (minimal, most packages go in Home Manager)
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
  ];
}
