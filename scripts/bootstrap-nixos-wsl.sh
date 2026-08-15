set -euo pipefail

flake_ref="${DOTFILES_FLAKE:-github:user3301/dotfiles}"
repo_url="${DOTFILES_REPO_URL:-https://github.com/user3301/dotfiles.git}"
target_user="user3301"
target_home="/home/${target_user}"
target_repo="${target_home}/dotfiles"
git_bin="$(command -v git)"

if [[ "${1:-}" == "--help" ]]; then
  cat <<EOF
Bootstrap this dotfiles configuration on an existing NixOS-WSL installation.

Environment overrides:
  DOTFILES_FLAKE     Flake reference used for the initial switch
  DOTFILES_REPO_URL  Git URL cloned into ${target_repo}
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

if [[ -d "${target_repo}/.git" ]]; then
  echo "Updating the existing checkout at ${target_repo}..."
  sudo -H -u "${target_user}" "${git_bin}" -C "${target_repo}" pull --ff-only
elif [[ -e "${target_repo}" ]]; then
  echo "error: ${target_repo} exists but is not a Git checkout" >&2
  exit 1
else
  echo "Cloning dotfiles into ${target_repo}..."
  sudo -H -u "${target_user}" "${git_bin}" clone "${repo_url}" "${target_repo}"
fi

echo "Activating the configuration from the local checkout..."
sudo nixos-rebuild switch --flake "${target_repo}#nixos-wsl"

cat <<EOF

NixOS-WSL bootstrap complete.
Run 'wsl --shutdown' from PowerShell, then reopen the distribution as ${target_user}.
EOF
