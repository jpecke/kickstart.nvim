#!/usr/bin/env bash
# User-space Neovim integration packages; no sudo and no system Python mutation.
set -euo pipefail
usage() {
  echo 'Usage: bash scripts/install-deps.sh --check|--apply'
  echo '--apply may download/install user-level npm/pipx packages and debugpy.'
}
[[ $# -eq 1 && ( "$1" == --check || "$1" == --apply ) ]] || { usage; exit 2; }
mode="$1"

# nvm lives in Bash startup files and can be absent in noninteractive SSH.
if ! command -v npm >/dev/null 2>&1 && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh"
fi

for exe in pipx npm python3; do
  command -v "$exe" >/dev/null 2>&1 || {
    echo "Missing $exe. Install/bootstrap it before this step." >&2
    exit 1
  }
done

check_or_install_pipx() {
  local cmd="$1" pkg="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd"
  elif [[ "$mode" == --apply ]]; then
    echo "Installing pipx package $pkg"
    pipx install "$pkg"
  else
    echo "MISSING: $cmd (pipx package: $pkg)"
  fi
}
check_or_install_pipx pynvim-python pynvim
check_or_install_pipx djlint djlint
check_or_install_pipx djls django-language-server

if npm list -g neovim --depth=0 >/dev/null 2>&1; then
  echo 'OK: npm neovim provider'
elif [[ "$mode" == --apply ]]; then
  npm install -g neovim
else
  echo 'MISSING: npm global neovim provider'
fi
if command -v tree-sitter >/dev/null 2>&1; then
  tree-sitter --version
elif [[ "$mode" == --apply ]]; then
  npm install -g tree-sitter-cli@0.27.2
else
  echo 'MISSING: tree-sitter CLI'
fi

debugvenv="$HOME/.local/share/nvim/debugpy-venv"
if [[ -x "$debugvenv/bin/python" ]] && "$debugvenv/bin/python" -c 'import debugpy' >/dev/null 2>&1; then
  echo 'OK: dedicated debugpy environment'
elif [[ "$mode" == --apply ]]; then
  mkdir -p "$(dirname "$debugvenv")"
  if [[ ! -x "$debugvenv/bin/python" ]]; then python3 -m venv "$debugvenv"; fi
  "$debugvenv/bin/python" -m pip install --upgrade debugpy
else
  echo "MISSING: $debugvenv debugpy environment"
fi

if [[ "$mode" == --check ]]; then
  echo 'Read-only check finished. Install optional missing packages using --apply.'
else
  echo 'User-space dependencies installed. Start nvim, allow Mason to install its tools,'
  echo 'then test :checkhealth and debugging on this host.'
fi
