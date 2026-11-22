#!/usr/bin/env bash
# Install managed Zellij/Bash helpers from a clone at ~/.config/nvim.
# Does NOT overwrite the Neovim config, change Git remotes, or install apt packages.
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: bash scripts/install.sh --check
       bash scripts/install.sh --apply

--check  Read-only preflight: verify repo files and host tools.
--apply  Back up changed target files, install Zellij helpers, and append a
         single guarded source block to ~/.bashrc. Requires Zellij >= 0.46.
EOF
}
[[ $# -eq 1 ]] || { usage; exit 2; }
mode="$1"
case "$mode" in --check|--apply) ;; *) usage; exit 2;; esac
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
if [[ "$root" != "$HOME/.config/nvim" ]]; then
  echo "Expected clone at ~/.config/nvim, got: $root" >&2
  echo "Clone/switch config first, then run this script again." >&2
  exit 1
fi
for name in zellij-copy-file zellij-paste-focused zpaste; do
  [[ -r "$root/extras/bin/$name" ]] || { echo "Missing extras/bin/$name" >&2; exit 1; }
done
[[ -r "$root/extras/zellij/config.kdl.in" ]] || { echo "Missing Zellij template" >&2; exit 1; }
[[ -r "$root/extras/bash/zellij-pane-naming.sh" ]] || { echo "Missing Bash snippet" >&2; exit 1; }

echo "Repository: $root"
echo "Host: $(hostname) | Home: $HOME"
for tool in nvim zellij node npm tree-sitter pipx python3; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK: %-12s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf 'MISSING: %s\n' "$tool"
  fi
done
if command -v nvim >/dev/null 2>&1; then nvim --version | head -n 1; fi
zellij_ok=0
if command -v zellij >/dev/null 2>&1; then
  version="$(zellij --version | awk '{print $2}')"
  echo "Zellij version: $version"
  if [[ "$version" =~ ^([0-9]+)\.([0-9]+)\. ]]; then
    major="${BASH_REMATCH[1]}"; minor="${BASH_REMATCH[2]}"
    if (( 10#$major > 0 || 10#$minor >= 46 )); then zellij_ok=1; fi
  fi
fi
if (( ! zellij_ok )); then
  echo 'WARNING: focused-pane background paste requires Zellij >= 0.46.' >&2
  if [[ "$mode" == --apply ]]; then
    echo 'Upgrade Zellij first; no files changed.' >&2
    exit 1
  fi
fi

[[ "$mode" == --apply ]] || {
  echo 'Read-only check complete. To install: bash scripts/install.sh --apply'
  exit 0
}

# Backups are kept under the user's home, never within the tracked repo.
timestamp="$(date -u +%Y%m%dT%H%M%SZ)-$$"
backup_root="$HOME/.local/state/nvim-zellij-backups/$timestamp"
backups=0
backup_if_changed() {
  local target="$1" candidate="$2" relative
  if [[ -e "$target" || -L "$target" ]]; then
    if cmp -s "$candidate" "$target"; then return 0; fi
    relative="${target#"$HOME"/}"
    mkdir -p "$backup_root/$(dirname "$relative")"
    cp -a -- "$target" "$backup_root/$relative"
    backups=$((backups+1))
  fi
}
install_managed() {
  local source="$1" target="$2" perm="$3"
  mkdir -p "$(dirname "$target")"
  backup_if_changed "$target" "$source"
  install -m "$perm" "$source" "$target"
  printf 'Installed %s\n' "$target"
}

mkdir -p "$HOME/.local/bin" "$HOME/.config/zellij" "$HOME/.cache"
chmod 700 "$HOME/.cache" 2>/dev/null || true
for name in zellij-copy-file zellij-paste-focused zpaste; do
  install_managed "$root/extras/bin/$name" "$HOME/.local/bin/$name" 0755
done
install_managed "$root/extras/bash/zellij-pane-naming.sh" \
  "$HOME/.config/zellij/pane-naming.sh" 0644

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
# Reconstitute paths from @HOME@. Values in this setup are normal Unix paths.
sed "s|@HOME@|$HOME|g" "$root/extras/zellij/config.kdl.in" > "$tmp"
install_managed "$tmp" "$HOME/.config/zellij/config.kdl" 0644

start_marker='# BEGIN managed nvim-zellij: pane naming'
end_marker='# END managed nvim-zellij: pane naming'
bashrc="$HOME/.bashrc"
[[ -f "$bashrc" ]] || touch "$bashrc"
if ! grep -Fqx "$start_marker" "$bashrc"; then
  mkdir -p "$backup_root"
  cp -a "$bashrc" "$backup_root/bashrc"
  backups=$((backups+1))
  cat >> "$bashrc" <<'EOF'

# BEGIN managed nvim-zellij: pane naming
if [[ -f "$HOME/.config/zellij/pane-naming.sh" ]]; then
  source "$HOME/.config/zellij/pane-naming.sh"
fi
# END managed nvim-zellij: pane naming
EOF
  echo "Appended pane-naming hook to $bashrc"
else
  echo "Pane-naming hook already present in $bashrc (unchanged)"
fi

if ! bash -n "$bashrc"; then
  echo "WARNING: ~/.bashrc has a syntax problem; review backup at $backup_root" >&2
  exit 1
fi
echo "Installation complete. Changed-file backups: $backups"
if (( backups > 0 )); then echo "Backups: $backup_root"; fi
echo 'Open a NEW Zellij session and new Bash shell to load the configuration.'
echo 'For language servers and debugpy: bash scripts/install-deps.sh --check'
