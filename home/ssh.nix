{ config, pkgs, lib, ... }:

{
  # SSH configuration via home-manager
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # SSH client configuration
    matchBlocks = {
      "*" = {};

      # Example: GitHub
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };

      # Add more hosts here as needed
      # "example.com" = {
      #   hostname = "example.com";
      #   user = "youruser";
      #   identityFile = "~/.ssh/id_ed25519";
      # };
    };

    # Additional SSH config options
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  # Note: home-manager cannot directly generate SSH keys automatically
  # because key generation should be interactive and secure.
  #
  # However, we can provide a systemd service or activation script
  # to generate keys on first run if they don't exist.

  # Activation script to generate SSH key if it doesn't exist
  home.activation.generateSshKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SSH_KEY="$HOME/.ssh/id_ed25519"

    if [ ! -f "$SSH_KEY" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD chmod 700 "$HOME/.ssh"

      echo "Generating SSH key at $SSH_KEY..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${config.home.username}@$(hostname)" -f "$SSH_KEY" -N ""

      echo ""
      echo "SSH key generated successfully!"
      echo "Public key:"
      $DRY_RUN_CMD cat "$SSH_KEY.pub"
      echo ""
      echo "Add this key to your GitHub/GitLab account."
    else
      echo "SSH key already exists at $SSH_KEY"
    fi
  '';
}
