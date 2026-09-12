# Login shells read this instead of ~/.bashrc, so source ~/.bashrc here to keep
# login and non-login interactive shells identical.
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
