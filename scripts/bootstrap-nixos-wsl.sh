set -euo pipefail

flake_ref="${DOTFILES_FLAKE:-github:user3301/dotfiles}"
target_user="user3301"

if [[ "${1:-}" == "--help" ]]; then
  cat <<EOF
Bootstrap this dotfiles configuration on an existing NixOS-WSL installation.

Environment overrides:
  DOTFILES_FLAKE  Flake reference used for the installation
EOF
  exit 0
fi

if ! grep -qi microsoft /proc/sys/kernel/osrelease; then
  echo "error: this bootstrap command is only for NixOS running under WSL2" >&2
  exit 1
fi

if ! command -v nixos-rebuild >/dev/null; then
  echo "error: nixos-rebuild was not found; start from a NixOS-WSL distribution" >&2
  exit 1
fi

# Fresh NixOS-WSL images may not have flakes enabled in their current generation.
export NIX_CONFIG="${NIX_CONFIG:-}"$'\nexperimental-features = nix-command flakes'

echo "Creating the ${target_user} NixOS configuration..."
sudo nixos-rebuild switch --flake "${flake_ref}#nixos-wsl-bootstrap"

cat <<EOF

NixOS-WSL bootstrap complete.
Run 'wsl --shutdown' from PowerShell, then reopen the distribution as ${target_user}.
EOF
