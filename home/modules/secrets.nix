{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Import sops-nix home-manager module
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Configure systemd to not auto-start services during activation
  # This prevents the "sops-nix.service not found" error during first activation
  systemd.user.startServices = "sd-switch";

  # Configure sops-nix
  sops = {
    # Default sops file for secrets
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Validate sops files at build time
    validateSopsFiles = false; # Set to true once secrets are encrypted

    # Age key configuration
    age = {
      # Path to age key file for decryption
      # IMPORTANT: You must manually copy your age key to this location on new machines
      # The same key must be used across all machines to decrypt the secrets
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Do NOT auto-generate - you need the same key across all machines
      generateKey = false;
    };

    # Define secrets to be managed
    secrets = {
      # SSH private key
      "ssh/id_ed25519" = {
        # Where to place the decrypted secret
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";

        # Set proper permissions for SSH key
        mode = "0600";
      };

      # SSH public key
      "ssh/id_ed25519.pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };

  # Ensure .ssh directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    onChange = ''
      chmod 700 ${config.home.homeDirectory}/.ssh
    '';
  };

  # Ensure .config/sops/age directory exists and persists through home-manager activations
  home.file.".config/sops/age/.keep" = {
    text = "";
    onChange = ''
      chmod 700 ${config.home.homeDirectory}/.config/sops
      chmod 700 ${config.home.homeDirectory}/.config/sops/age
    '';
  };

  # Add sops to home packages for manual secret management
  home.packages = with pkgs; [
    sops
    age
  ];
}
