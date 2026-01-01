# Secrets Management with sops-nix

This document explains how to manage secrets in your dotfiles using sops-nix and age encryption.

## Overview

This dotfiles repository uses sops-nix to manage sensitive data like SSH keys. Secrets are encrypted with age keys and automatically decrypted when you run `make switch` or apply your Home Manager configuration.

## Architecture

- **Encryption**: Uses age (modern encryption tool)
- **Secret Management**: sops-nix handles decryption and placement
- **Key Location**: `~/.config/sops/age/keys.txt`
- **Encrypted Secrets**: `secrets/secrets.yaml` (encrypted, safe to commit)
- **Configuration**: `.sops.yaml` defines encryption rules

## Initial Setup

### 1. Generate Age Key (First Time Only)

On your current machine with existing secrets:

```bash
# Create the age directory
mkdir -p ~/.config/sops/age

# Generate your age key
age-keygen -o ~/.config/sops/age/keys.txt

# Display your public key (you'll need this)
age-keygen -y ~/.config/sops/age/keys.txt
```

This will output something like:
```
age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 2. Update .sops.yaml with Your Public Key

Edit `/home/user3301/dotfiles/.sops.yaml` and replace the placeholder:

```yaml
keys:
  - &user_age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Replace `age1xxx...` with your actual public key from the previous step.

### 3. Create Your Secrets File

```bash
cd /home/user3301/dotfiles

# Copy the example template
cp secrets/secrets.yaml.example secrets/secrets.yaml

# Edit the file and add your actual secrets
# For SSH keys, paste the ENTIRE content including BEGIN/END lines
nano secrets/secrets.yaml  # or use your preferred editor
```

Example structure:
```yaml
ssh:
  id_ed25519: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    (your actual private key content)
    -----END OPENSSH PRIVATE KEY-----

  id_ed25519.pub: ssh-ed25519 AAAAC3... your-email@example.com
```

### 4. Encrypt the Secrets File

```bash
# Make sure you have sops installed
nix-shell -p sops

# Encrypt the file in place
sops -e -i secrets/secrets.yaml
```

After encryption, the file will contain sops metadata and encrypted content. It's now safe to commit to git.

### 5. Verify Encryption

```bash
# View the encrypted file
cat secrets/secrets.yaml

# You should see sops metadata at the top like:
# sops:
#     kms: []
#     gcp_kms: []
#     azure_kv: []
#     hc_vault: []
#     age:
#         - recipient: age1xxx...
#           enc: -----BEGIN AGE ENCRYPTED FILE-----
```

## Using Secrets on a New Machine

### Scenario 1: New NixOS/WSL2 Machine

```bash
# 1. Clone your dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Copy your age key to the new machine
# (Transfer ~/.config/sops/age/keys.txt securely from your old machine)
mkdir -p ~/.config/sops/age
# Copy the keys.txt file here

# 3. Update flake inputs
nix flake update

# 4. Run make switch (NixOS/WSL2)
make switch

# Your SSH keys will be automatically decrypted and placed in ~/.ssh/
```

### Scenario 2: Arch Linux with Home Manager

```bash
# 1. Clone your dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Copy your age key
mkdir -p ~/.config/sops/age
# Copy keys.txt here

# 3. Install nix (if not already installed)
make install-nix

# 4. Apply home-manager configuration
make setup-home-manager

# Your secrets will be decrypted and placed automatically
```

### Scenario 3: You Lost Your Age Key

If you lost your age key but still have access to the unencrypted secrets:

```bash
# 1. Generate a new age key
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # Get new public key

# 2. Update .sops.yaml with the new public key
# Edit .sops.yaml and replace the old key

# 3. Re-encrypt your secrets
# First, create a fresh unencrypted secrets.yaml from your sources
cp secrets/secrets.yaml.example secrets/secrets.yaml
# Edit and add your actual secrets

# 4. Encrypt with the new key
sops -e -i secrets/secrets.yaml

# 5. Commit the updated .sops.yaml and re-encrypted secrets.yaml
git add .sops.yaml secrets/secrets.yaml
git commit -m "Update encryption key"
git push
```

## Managing Secrets

### View Encrypted Secrets

```bash
# Decrypt and view in your editor
sops secrets/secrets.yaml

# This temporarily decrypts for viewing/editing
# When you save and exit, it re-encrypts automatically
```

### Add New Secrets

```bash
# Edit the encrypted file
sops secrets/secrets.yaml

# Add new secrets in YAML format
# Example:
github:
  token: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Save and exit - sops will re-encrypt automatically
```

### Update Existing Secrets

```bash
# Edit the encrypted file
sops secrets/secrets.yaml

# Modify the values you need
# Save and exit

# Commit the changes
git add secrets/secrets.yaml
git commit -m "Update secrets"
git push
```

### Add a Secret to Home Manager

After adding a secret to `secrets/secrets.yaml`, you need to configure sops-nix to use it:

Edit `/home/user3301/dotfiles/home/modules/secrets.nix`:

```nix
secrets = {
  # Existing secrets...

  # Add new secret
  "github/token" = {
    path = "${config.home.homeDirectory}/.config/github/token";
    mode = "0600";
  };
};
```

Then rebuild:
```bash
make switch  # or make setup-home-manager for Arch
```

## Security Best Practices

1. **Never commit unencrypted secrets**: Always encrypt with sops before committing
2. **Backup your age key**: Store `~/.config/sops/age/keys.txt` in a secure location
3. **Use proper permissions**: sops-nix automatically sets correct file permissions
4. **Rotate keys periodically**: Generate new SSH keys and age keys periodically
5. **Use different keys for different contexts**: Consider separate keys for work/personal

## Troubleshooting

### Error: "no key could be found"

This means sops can't find your age key. Solutions:
```bash
# Check if key exists
ls -la ~/.config/sops/age/keys.txt

# Verify the key file is readable
cat ~/.config/sops/age/keys.txt

# Make sure .sops.yaml has the correct public key
age-keygen -y ~/.config/sops/age/keys.txt
# Compare with the key in .sops.yaml
```

### Error: "secrets file not found"

```bash
# Make sure secrets.yaml exists and is encrypted
ls -la /home/user3301/dotfiles/secrets/secrets.yaml

# Verify it's encrypted (should have sops metadata)
head -20 /home/user3301/dotfiles/secrets/secrets.yaml
```

### Secrets not decrypting

```bash
# Check sops-nix configuration
cat /home/user3301/dotfiles/home/modules/secrets.nix

# Verify the defaultSopsFile path is correct
# Try manual decryption to test
sops -d secrets/secrets.yaml
```

### Testing the setup before commit

```bash
# Build but don't activate
nix build .#homeConfigurations."user@linux".activationPackage  # Arch
sudo nixos-rebuild build --flake .#nixos-wsl  # NixOS WSL2

# If build succeeds, your configuration is valid
```

## File Locations Reference

| File | Purpose | Should Commit? |
|------|---------|----------------|
| `.sops.yaml` | Encryption rules | Yes |
| `secrets/secrets.yaml` | Encrypted secrets | Yes (only if encrypted) |
| `secrets/secrets.yaml.example` | Template | Yes |
| `~/.config/sops/age/keys.txt` | Your age private key | NO - backup securely |
| `home/modules/secrets.nix` | sops-nix config | Yes |

## Advanced: Multiple Machines with Different Keys

If you want different machines to have different keys:

1. Add all public keys to `.sops.yaml`:
```yaml
keys:
  - &machine1 age1xxx...
  - &machine2 age1yyy...

creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *machine1
          - *machine2
```

2. Re-encrypt secrets with all keys:
```bash
sops updatekeys secrets/secrets.yaml
```

Now any machine with either key can decrypt the secrets.

## Workflow Summary

### Initial Setup (Once)
1. Generate age key
2. Update .sops.yaml with public key
3. Create and encrypt secrets.yaml
4. Commit to git

### On New Machine
1. Clone dotfiles
2. Copy age key to ~/.config/sops/age/keys.txt
3. Run `make switch` or `make setup-home-manager`
4. Secrets auto-decrypt to correct locations

### Adding/Updating Secrets
1. `sops secrets/secrets.yaml`
2. Edit, save, exit (auto re-encrypts)
3. Update secrets.nix if adding new secrets
4. Commit and push
5. `make switch` on all machines
