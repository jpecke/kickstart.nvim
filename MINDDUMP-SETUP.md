# Primary → GitHub → Minddump

This repository is your **working Neovim 0.12 + Zellij 0.46 configuration**.
`init.lua` stays at the repository root because you will clone directly to
`~/.config/nvim`. All other system integration lives under `extras/` and
`scripts/`. The current Neovim/Zellij cheat sheets are included under `docs/`. These instructions do not delete existing Minddump applications,
Docker containers, or system Python packages.

## A. Capture the LIVE Primary setup (not the older audit snapshot)

Download `neovim-zellij-repo-kit.zip` and extract it inside the existing
`~/.config/nvim` Git working tree:

```bash
cd ~/.config/nvim
unzip -o ~/Downloads/neovim-zellij-repo-kit.zip
bash scripts/capture-primary.sh
```

`capture-primary.sh` copies the current Zellij config and three clipboard
scripts from Primary into this repository. It replaces `/home/justin` paths in
the Zellij config with `@HOME@` so the installer can restore the target user's
home path. It also fixes `.gitignore` to track `nvim-pack-lock.json` and to
ignore local `init.lua` backups.

The original auto-naming routine is in Primary's `~/.bashrc` and wasn't part
of the original archive. The portable equivalent in
`extras/bash/zellij-pane-naming.sh` has the same intended behavior and avoids
adding the Bash `PROMPT_COMMAND` hook twice.

Review changed files and any personal data **before pushing to a public repo**:

```bash
git status --short
git diff --stat
git diff -- .gitignore
grep -RInE '(token|password|api[_-]?key|secret)' extras/ || true
```

## B. Redirect Primary's Git remotes safely

This assumes Primary was cloned from `nvim-lua/kickstart.nvim` and you have
not previously changed its remotes. Verify the actual state first:

```bash
cd ~/.config/nvim
git remote -v
git branch --show-current
git status --short
```

The desired remotes are:

- `origin`: `git@github.com:jpecke/kickstart.nvim.git`
- `upstream`: `https://github.com/nvim-lua/kickstart.nvim.git`

If `origin` currently points to upstream, use:

```bash
git remote rename origin upstream
git remote add origin git@github.com:jpecke/kickstart.nvim.git
```

If your current `origin` already points to `jpecke`, **do not rename it**.
Simply add an `upstream` remote if missing. HTTPS may be used instead of SSH
if GitHub SSH authentication isn't configured.

## C. Publish while keeping the old GitHub history

The previous repository uses older Lazy.nvim-based Kickstart. Keep its
history available and make the new version its current working tree. Do not
force-push and do not delete the old repository.

```bash
cd ~/.config/nvim
git fetch origin master
# Review changes before committing:
git add -A
git diff --cached --check
git diff --cached --stat
# Inspect `git status` and ensure no personal backups/secrets are staged.
git commit -m "Build unified Neovim and Zellij development configuration"

# Preserve current GitHub master on a named remote backup branch.
git branch legacy-kickstart-backup origin/master
git push origin legacy-kickstart-backup:legacy-kickstart-backup

# Merge only ancestry; keep Primary's files exactly as they currently are.
# This is a non-destructive merge in Git history, NOT a filesystem merge.
git merge -s ours --allow-unrelated-histories origin/master -m "Retain legacy fork history; keep Primary configuration"

# A normal fast-forward push updates the GitHub master working tree.
git push -u origin HEAD:master
```

The merge may say `Already up to date` if the history was already an ancestor.
If the push fails because GitHub changed in the meantime, re-fetch and review;
**do not use `--force`**. If the current branch is not the intended Primary
branch, stop and inspect with `git branch -avv` before committing.

## D. Install on Minddump (once GitHub is updated)

Minddump already has Neovim installed but its old config must be preserved.
Do these steps **on Minddump**, not on Primary:

```bash
# Quit nvim sessions using this config first.
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
if [ -e "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.before-primary-$stamp"
fi
# Make sure ~/.config exists.
mkdir -p ~/.config
git clone https://github.com/jpecke/kickstart.nvim.git ~/.config/nvim
cd ~/.config/nvim
bash scripts/install.sh --check
```

**Zellij 0.46 or later is required** for the background focused-pane paste
shortcut. The installer refuses `--apply` on older Zellij versions. Upgrade
Minddump's Zellij first if it still has `0.45.1`.

Once the check is satisfactory:

```bash
bash scripts/install.sh --apply
bash scripts/install-deps.sh --check
# Optional: install any missing user-level pipx/npm/debugpy tools:
bash scripts/install-deps.sh --apply
```

`install.sh` backs up changed Zellij config, helper scripts, and `.bashrc` into
`~/.local/state/nvim-zellij-backups/<timestamp>/`. It only appends the Bash
source snippet once. It leaves `~/.config/nvim/init.lua` and system Python alone.

Start a **new** SSH Bash session and new Zellij session to apply naming and
keybindings. Then launch Neovim and allow Mason/Tree-sitter to install the
necessary language servers/parsers. Neovim can take time to populate user
caches on the first launch, but this setup does not require X11 or Wayland.

## E. Verify Minddump before Django Docker debugging

```bash
nvim --version | head -n 1
zellij --version
node --version
npm --version
tree-sitter --version
djlint --version
djls --version
~/.local/share/nvim/debugpy-venv/bin/python -m debugpy --version
bash -n ~/.bashrc
```

Inside a Python file, test `:checkhealth vim.lsp` and `:ConformInfo`. Test the
Zellij clipboard shortcuts, pane `terminal_N` naming, and scrollback editor.
Use the same tests already verified on Primary. Django Docker debugging comes
**after** the Minddump environment is verified; don't modify the work app's
Docker configuration in the bootstrap phase.

## Updating later

On Primary: edit and test, `git add/commit/push`. On Minddump: `git pull
--ff-only`, `bash scripts/install.sh --apply` if extras changed, and optionally
`bash scripts/install-deps.sh --check`. Keep any host-specific secrets and
project virtual environments OUTSIDE this repo.
