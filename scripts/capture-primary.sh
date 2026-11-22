#!/usr/bin/env bash
# Capture CURRENT working Primary Zellij setup into this repository.
# Does NOT modify live ~/.config/zellij or ~/.bashrc.
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
[[ "$root" == "$HOME/.config/nvim" ]] || {
  echo "WARNING: repository is at $root (not ~/.config/nvim)." >&2
}
[[ -f "$HOME/.config/zellij/config.kdl" ]] || {
  echo "Missing ~/.config/zellij/config.kdl" >&2; exit 1;
}
for name in zellij-copy-file zellij-paste-focused zpaste; do
  [[ -f "$HOME/.local/bin/$name" ]] || {
    echo "Missing ~/.local/bin/$name" >&2; exit 1;
  }
done

mkdir -p "$root/extras/zellij" "$root/extras/bin"
# Convert Primary's home-directory paths to a portable placeholder.
sed "s|$HOME|@HOME@|g" \
  "$HOME/.config/zellij/config.kdl" > "$root/extras/zellij/config.kdl.in"
for name in zellij-copy-file zellij-paste-focused zpaste; do
  install -m 0755 "$HOME/.local/bin/$name" "$root/extras/bin/$name"
done

# The lockfile must be tracked in your personal repo.
[[ -f "$root/nvim-pack-lock.json" ]] || {
  echo "Missing nvim-pack-lock.json: open Neovim to create it first." >&2
  exit 1
}
if [[ -f "$root/.gitignore" ]]; then
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  awk '$0 != "nvim-pack-lock.json" {print}' "$root/.gitignore" > "$tmp"
  cat >> "$tmp" <<'EOF'

# Local configuration backups are not part of the shared installation.
init.lua.pre-*
init.lua.backup-*
*.backup-*
*.bak.*
EOF
  # Avoid appending the backup patterns on every run.
  awk '!seen[$0]++ || $0 == ""' "$tmp" > "$root/.gitignore"
fi

echo "Captured live Primary Zellij configuration and scripts."
echo "The repo's extras/bash/zellij-pane-naming.sh is a portable equivalent"
echo "of the working pane-naming hook, not a copy of your entire ~/.bashrc."
echo "NEXT: review: git status --short ; git diff ; git diff --cached"
