# Secrets Management Quick Start

Quick reference for managing secrets with sops-nix in your dotfiles.

## First Time Setup

```bash
# 1. Generate age key
make secrets-init

# 2. Copy the public key shown and update .sops.yaml
# Replace the placeholder in .sops.yaml with your actual public key

# 3. Create secrets file from template
cp secrets/secrets.yaml.example secrets/secrets.yaml

# 4. Edit and add your actual secrets
nano secrets/secrets.yaml

# 5. Encrypt the file
make secrets-encrypt

# 6. Commit to git
git add .sops.yaml secrets/secrets.yaml
git commit -m "Add encrypted secrets"
git push
```

## On a New Machine

```bash
# 1. Clone your dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Copy your age key to the new machine
# Transfer ~/.config/sops/age/keys.txt from your old machine
mkdir -p ~/.config/sops/age
# Copy keys.txt here

# 3. Run make switch
make switch  # NixOS/WSL2
# OR
make setup-home-manager  # Arch Linux

# Secrets will be automatically decrypted to ~/.ssh/
```

## Common Commands

```bash
make secrets-check      # Check if age key exists and secrets are encrypted
make secrets-edit       # Edit encrypted secrets (auto re-encrypts on save)
make secrets-decrypt    # View decrypted secrets in terminal
```

## What Gets Decrypted and Where

After running `make switch`, the following happens automatically:

- `secrets.yaml` (encrypted) is read by sops-nix
- Private key is decrypted to `~/.ssh/id_ed25519` (mode 0600)
- Public key is decrypted to `~/.ssh/id_ed25519.pub` (mode 0644)

## Adding New Secrets

```bash
# 1. Edit the encrypted secrets file
make secrets-edit

# 2. Add your new secret in YAML format
# Example:
# github:
#   token: ghp_xxxxxxxxxxxx

# 3. Update home/modules/secrets.nix to use the new secret
# Add a new entry in the secrets = { } block

# 4. Rebuild
make switch
```

## Important Files

- `.sops.yaml` - Encryption rules (commit this)
- `secrets/secrets.yaml` - Encrypted secrets (commit this when encrypted)
- `~/.config/sops/age/keys.txt` - Your age private key (NEVER commit this)
- `home/modules/secrets.nix` - sops-nix configuration

## Security Checklist

- [ ] Age key backed up securely
- [ ] secrets.yaml is encrypted before committing
- [ ] Public key in .sops.yaml matches your age key
- [ ] Can decrypt secrets: `make secrets-decrypt`

For detailed documentation, see [SECRETS-MANAGEMENT.md](/home/user3301/dotfiles/docs/SECRETS-MANAGEMENT.md)
