# Neovim + Zellij: Complete Working Reference

**Customized for the Primary computer's uploaded configuration** · Reviewed November 2026<br>
**Editor:** Neovim 0.12.6 / current Kickstart using `vim.pack`<br>
**Terminal manager:** Zellij 0.46.x, **Unlock-First** preset<br>
**Development focus:** Python, Django, HTMX, HTML/CSS/JavaScript, JSON/YAML, Docker, Git; kmscon and SSH-compatible workflows<br>
**Primary source of truth:** the uploaded `neovim-zellij-audit.tar.gz`, not the older `jpecke/kickstart.nvim` configuration or the original cheat sheets.

> **Scope:** This is a guide to **the configuration found in your archive**, together with ordinary Neovim/Zellij commands. It does not claim to have run your live programs. You have separately reported that the core features work on Primary. Minddump deployment and Docker-based Django debugging are still pending.

## 1. Read the shortcut notation

| Notation | Meaning |
| --- | --- |
| `Space` or `<leader>` | Your Neovim leader key is **Space** |
| `Space s f` | Press Space, release, then `s`, then `f` |
| `Ctrl+h` / `<C-h>` | Hold Ctrl and press `h` |
| `Ctrl+g → p → v` | Unlock Zellij, enter Pane mode, press `v` |
| `\` | Press the **backslash** key |
| `:` commands | Enter in Neovim **Normal mode**, then Enter |
| `n / i / v / x / t` | Neovim Normal / Insert / Visual / Visual-or-Select / terminal-input modes |

**First rescue action:** press `Esc` to get to Normal mode, then `:w` to save. In Neovim's built-in terminal, `Esc Esc` leaves terminal-input mode. **Zellij's `Ctrl+g` is separate from Neovim's Space leader.**

**Find an unknown Neovim shortcut:** press Space and read **which-key**, or use `Space s k`. **Find Zellij commands:** `Ctrl+g`, then read the mode bar; press `Esc` or `Ctrl+g` as appropriate to return to Locked mode.

## 2. Typical session: local or remote

### Local files on Primary

```bash
cd ~/path/to/project
zellij attach --create primary-dev  # when launching from a shell outside Zellij
nvim .                               # or: nvim views.py
```

Inside Zellij, use another pane for tests, Docker logs, Git, or a future terminal-chat client. When already **inside** Zellij, do not launch a nested Zellij session accidentally.

### Projects located on Minddump (once configured)

```bash
ssh minddump
zellij attach --create minddump-dev
cd ~/path/to/project
nvim .
```

Run Neovim **on the machine that owns the project**. The primary computer is the SSH display terminal; language servers, formatters, and Python environments on Minddump run there. You do not have to open Neovim locally first.

### Session continuity

From **outside** Zellij:

```bash
zellij list-sessions
zellij attach --create primary-dev
zellij attach primary-dev
```

Inside Zellij, your current config provides **`Ctrl+g → o → d`** for *Session mode → Detach*. Reconnect by attaching to the session. Detaching preserves running session processes, but a reboot or crash is not the same as detach. Avoid nested local/SSH Zellij sessions unless you specifically intend them.

## 3. Neovim essentials — everyday editing

| Goal | Keys / command | Comments |
| --- | --- | --- |
| Start editing / return to Normal | `i` / `Esc` | `a`, `o`, `O` also enter Insert mode |
| Save | `:w` | Writes the current file |
| Save and exit | `:wq` | `:x` is also useful |
| Exit | `:q` | Confirm prompt if unsaved changes; `:q!` discards them |
| Undo / redo | `u` / `Ctrl+r` | Undo/redo edits |
| Copy current line | `yy` | Internal Neovim register; works independently of Zellij |
| Delete current line | `dd` | `p` can paste deleted text |
| Paste after / before | `p` / `P` | Neovim registers |
| Select lines | `V`, then movement | `v` selects characters; `Ctrl+v` blockwise select |
| Change inside word | `ciw` | Delete word and enter Insert mode |
| Change inside quotes | `ci'` or `ci"` | Uses text objects |
| Delete inside parentheses | `di(` | Other text objects work similarly |
| Indent / unindent | `>>` / `<<` | Indent current line; visual selection then `>`/`<` |
| Repeat last change | `.` | Very useful for repetitive edits |
| Search in file | `/pattern`, Enter | `n` next, `N` previous; `Esc` clears highlighting |
| Current cursor word | `*` / `#` | Search forward/backward |
| Replace in entire file | `:%s/old/new/g` | Add `c` for confirmation (`gc`) |
| Open command line | `:` | `:messages` shows past errors |

### Movements worth memorizing

| Keys | Movement |
| --- | --- |
| `h j k l` | Left / down / up / right |
| `w b e` | Next word / previous word / end of word |
| `0` / `^` / `$` | Start of line / first nonblank / end of line |
| `gg` / `G` | Top / bottom of file |
| `:42` or `42G` | Go to line 42 |
| `Ctrl+d` / `Ctrl+u` | Half page down / up |
| `Ctrl+o` / `Ctrl+i` | Older / newer jump location |
| `%` | Matching paired delimiter when applicable |

### Splits, buffers, and in-editor terminal

| Keys / command | Purpose |
| --- | --- |
| `:vsplit` / `:split` | Vertical / horizontal split |
| `Ctrl+h/j/k/l` | Move across Neovim windows; with `zellij-nav`, cross to a neighboring Zellij pane at an editor edge |
| `:close` | Close focused split/window |
| `:ls` | Show open buffers |
| `:bnext` / `:bprevious` | Change buffer |
| `Space Space` | Telescope buffer selector |
| `:terminal` | Open a built-in terminal |
| `Esc Esc` | Exit Neovim terminal-input mode (your configured mapping) |
| `:q` | Close terminal window or temporary info window when applicable |

Neovim windows are **not** Zellij panes: a Neovim split stays inside one Zellij pane. `Ctrl+h/j/k/l` can cross that boundary because you installed `zellij-nav.nvim`.

## 4. Find anything — Telescope and Neo-tree

### Telescope (all are configured, not guessed)

| Shortcut | Result |
| --- | --- |
| `Space s f` | Search files by filename |
| `Space s g` | Live grep **project contents** with `rg` |
| `Space s w` | Grep word or selected text |
| `Space /` | Fuzzy search within current buffer |
| `Space s /` | Grep across open buffers |
| `Space Space` | Switch open buffers |
| `Space s .` | Recent files |
| `Space s r` | Resume previous search |
| `Space s s` | List Telescope pickers |
| `Space s d` | Search diagnostics |
| `Space s c` | Search commands |
| `Space s k` | Search defined keymaps |
| `Space s h` | Search help topics |
| `Space s n` | Search your Neovim configuration directory |

In a Telescope picker: **type to filter**, `Ctrl+n` / `Ctrl+p` moves the selection, `Enter` opens, `Esc` cancels. `Ctrl+/` in Insert mode (or `?` in Normal mode within Telescope) shows its own mappings. Your Kickstart has the FZF-native extension when `make` is present.

### Neo-tree

Press **`\`** (backslash) in Normal mode to reveal the current file in Neo-tree. When focused inside the tree, press `?` for its complete local map (best source if a plugin version changes).

Common Neo-tree keys: `j`/`k` move, `Enter` opens, `a` creates, `r` renames, `d` deletes, and `\` closes the tree. Take care with `d`: it changes the filesystem. Nerd Font icons work because `vim.g.have_nerd_font = true` and Kickstart initializes `mini.icons`.

## 5. Intelligent code editing — LSP, completion, formatting

Your configuration uses **Mason**, `nvim-lspconfig`, **blink.cmp**, **Conform**, Tree-sitter, Pyright, Ruff, djls, djLint, and other language servers. LSP keys only work when a suitable server is attached to the **current file**.

| Shortcut | Code action |
| --- | --- |
| `grd` | Go to definition via Telescope (not the old `gd` mapping) |
| `grr` | Find references |
| `gri` | Find implementation |
| `grt` | Go to type definition |
| `grD` | Go to declaration |
| `grn` | Rename symbol across references |
| `gra` | Code action / quick fix |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `K` | LSP hover documentation (when available) |
| `Space t h` | Toggle inlay hints if supported |
| `Space q` | Diagnostic location list |
| `Space s d` | Search diagnostics with Telescope |
| `Space f` | Format current buffer or selected range through Conform |

`Ctrl+t` returns from a definition jump; `Ctrl+o` is another way to go back through jumps. Some LSP mappings (`gr*`) are only created after a language server attaches.

### Completion: inside Insert mode

| Keys | Action |
| --- | --- |
| `Ctrl+Space` | Trigger completion menu; press again for documentation when available |
| `Ctrl+n` / `Ctrl+p` | Next / previous completion |
| `Ctrl+y` | Accept selected suggestion (default blink.cmp preset) |
| `Ctrl+e` | Hide suggestions |
| `Ctrl+k` | Toggle signature help |
| `Tab` / `Shift+Tab` | Navigate within snippet expansion, where applicable |

**Syntax colors ≠ suggestions.** Tree-sitter provides highlighting; the LSP supplies language intelligence; blink.cmp shows completion items. Terminal capabilities affect whether every Ctrl combination is transmitted.

### Installed/configured language support

| Files | Configuration present in archive |
| --- | --- |
| Python (`.py`) | Pyright + Ruff; Ruff formatting via Conform |
| Django template (`templates/*.html`) | `htmldjango` filetype, djls, djLint, HTML LSP, HTMX custom data |
| HTML / CSS | `html` / `cssls` |
| JavaScript / TypeScript | `tsc` language server |
| JSON / YAML | `jsonls` / `yamlls` |
| Dockerfile | `dockerls` |
| Docker Compose filenames | `yaml.docker-compose`, dedicated Docker Compose language service |
| Lua (`init.lua`) | `lua_ls`, `stylua` tool |
| Tailwind/DaisyUI | Tailwind LSP configured; class completion **not validated** with your CDN-only projects |

**Django work-app debugging inside Docker is not configured/tested yet.** Standalone Python debugging is working on Primary. Different systems use different Python versions; each project can have its own `.venv` or container runtime.

### Formatting caveat

`Space f` calls Conform; automatic formatting on save is **not enabled** for Python or Django templates in this archive. For Python it selects Ruff. On Django templates, formatting may fall back to a language server (djLint); it can collapse multiline HTMX attributes. You chose to defer that style change. Undo an unwanted format immediately with `u`.

### mini.nvim text objects and surrounding text

| Keys | Meaning |
| --- | --- |
| `saiw)` | Wrap the word under the cursor in parentheses |
| `sd'` | Remove surrounding single quotes |
| `sr)'` | Replace surrounding `)` pairing with single quotes |
| `va)` | Visually select around parentheses |
| `ci'` | Change inside quotes |
| `aa` / `ii` | mini.ai next-textobject variants; see `:help mini.ai` |

`mini.statusline` displays file/mode/status, `guess-indent` detects indentation, `todo-comments` highlights notes, and `which-key` shows mappings. These are installed and initialized in the uploaded config.

## 6. Git work from Neovim

Gitsigns adds change markers to the left gutter and hunk operations. Most mappings only appear when working in a Git-tracked buffer.

| Shortcut | Meaning |
| --- | --- |
| `]c` / `[c` | Next / previous changed hunk |
| `Space h p` | Preview change |
| `Space h i` | Inline preview |
| `Space h s` | Stage hunk (selected lines in Visual mode) |
| `Space h r` | **Reset hunk** (destructive to unstaged edits) |
| `Space h S` | Stage entire buffer |
| `Space h R` | **Reset buffer** (destructive) |
| `Space h b` | Blame current line |
| `Space h d` | Diff against Git index |
| `Space h D` | Diff against previous commit |
| `Space h q` / `Space h Q` | Changed-file / repo quickfix list |
| `Space t b` / `Space t w` | Toggle blame / word-diff |
| `ih` (text object) | Select current Git hunk in Visual/operator mode |

For everyday repository operations, use a separate **Zellij terminal pane**: `git status`, `git diff`, `git add`, `git commit`. The built-in Git signs are not a full Git client. Test destructive reset operations on scratch work first.

## 7. Python debugger — configured and tested

Your custom module: `~/.config/nvim/lua/custom/python_debug.lua`. It loads `nvim-dap`, `nvim-dap-ui`, and `nvim-nio`. The adapter runs the Python interpreter at `~/.local/share/nvim/debugpy-venv/bin/python` with `-m debugpy.adapter`; the target program prefers `$VIRTUAL_ENV`, then a `.venv` / `venv` in the Neovim working directory, then `python3`.

| Shortcut | Debugging action |
| --- | --- |
| `Space d b` | Toggle breakpoint at cursor |
| `Space d c` | Start / continue |
| `Space d n` | Step over |
| `Space d i` | Step into |
| `Space d o` | Step out |
| `Space d u` | Toggle debugger UI |
| `Space d x` | Terminate debug session |

**Simple test:** open a `.py` file, put cursor on an executable line, `Space d b`, then `Space d c`. In the UI inspect variables, stack, and breakpoint list. The debugging adapter is distinct from the project's Python interpreter. When the work app runs in Docker on Minddump, use a dedicated remote/attach configuration later, not this local-file launch profile.

## 8. Zellij Unlock-First — what the config actually binds

Your Zellij `~/.config/zellij/config.kdl` has `default_mode "locked"` and a `keybinds clear-defaults=true` map. In **Locked** mode, most letters go to the program running in the pane. Press **`Ctrl+g`** to enter Zellij's Normal mode. Then select a mode:

| From Locked | Mode |
| --- | --- |
| `Ctrl+g → p` | Pane |
| `Ctrl+g → t` | Tab |
| `Ctrl+g → s` | Scroll |
| `Ctrl+g → r` | Resize |
| `Ctrl+g → m` | Move pane |
| `Ctrl+g → o` | Session |
| `Ctrl+g` again, or `Esc` from most unlocked modes | Return to Locked (depending on active mode) |

### Pane commands (press `Ctrl+g → p` first)

| Final key | Result from your `pane` block |
| --- | --- |
| `h` / `j` / `k` / `l` | Focus left / down / up / right pane |
| `n` | New pane, automatically return to Locked |
| `r` | New pane to right |
| `d` | New pane below |
| `s` | New stacked pane |
| `x` | Close focused pane |
| `f` | Fullscreen focused pane toggle |
| `w` | Toggle floating panes |
| `z` | Toggle pane frames |
| `c` | Start rename-pane mode |
| `tab` | Switch focus |
| **`v`** | **Paste your shared clipboard into the focused pane**, via background script; return to Locked |

**Your Bash auto-title feature** renames newly spawned interactive Bash panes `terminal_N`, where `N` is their Zellij pane ID. The relevant shell startup code was **not included** in the archive, so it needs to be exported separately when moving to Minddump.

### Tab commands (press `Ctrl+g → t` first)

| Final key | Result |
| --- | --- |
| `n` | New tab |
| `h` / `l` | Previous / next tab |
| `1` … `9` | Jump to tab number |
| `r` | Rename tab |
| `x` | Close current tab |
| `tab` | Toggle last-used tab |
| `[` / `]` | Break pane to left / right (advanced) |

### Scroll mode (press `Ctrl+g → s` first)

| Final key | Result |
| --- | --- |
| `e` | Open current pane's scrollback in **Neovim** (configured absolute path) |
| `c` | Copy last command output **if OSC 133 shell integration has marked it** |
| `j` / `k` | Scroll down / up |
| `Ctrl+b` / `Ctrl+f` | Page up / down |
| `u` / `d` | Half-page up / down |
| `f` | Search in scrollback |
| `[` / `]` | Previous / next shell prompt marker (when available) |

**Other**: `Ctrl+g → r`, then `h/j/k/l` resizes; `Ctrl+g → m`, then `h/j/k/l` moves panes; **`Ctrl+g → o → d` detaches** the current session. The config also has shared `Alt+h/j/k/l` navigation in Locked/Normal modes, but those depend on what your terminal transmits. For uncertain keys, use Zellij's visible key hints or inspect `config.kdl`.

## 9. Complete copy/paste workflow — no graphical clipboard required

### A. Why this setup is special

Neovim's normal `yy`, `p`, `v` and related commands use *internal* registers inside Zellij (`clipboard` is set to empty there). Previously, a forced OSC 52 provider timed out in your terminal; you removed it. **Copying between panes uses a user-private file**, not Wayland/X11 and not OSC 52.

Source-of-truth paths:

```text
~/.cache/zellij-clipboard.txt          # Latest copied content
~/.local/bin/zellij-copy-file         # Receives text on standard input
~/.local/bin/zellij-paste-focused     # Paste to focused pane, background Zellij Run action
~/.local/bin/zpaste                   # Paste to a named terminal_N pane from shell
```

Your Zellij config sets:

```kdl
copy_command "/home/justin/.local/bin/zellij-copy-file"
scrollback_editor "/home/justin/.local/bin/nvim"
```

### B. The four shortcuts to memorize

| From | Keys | What happens |
| --- | --- | --- |
| Neovim Normal mode | **`Space z c`** | Copy the **current whole line** into the shared file |
| Neovim Visual mode | **select lines → `Space z c`** | Copy selected lines into shared file |
| Neovim Normal mode | **`Space z p`** | Insert shared-file lines **below** cursor |
| Neovim Normal mode | **`Space z s`** | Prompt for `terminal_N`; paste shared text to that pane |
| Any focused terminal pane | **`Ctrl+g → p → v`** | Paste shared text **into this pane**, no target ID needed |

### C. Terminal-chat → Neovim (keyboard-only; your main use case)

1. In the chat terminal pane, focus the output you want to copy.
2. `Ctrl+g → s → e` opens the pane's scrollback in Neovim.
3. In this scrollback editor, select lines with `V` and navigation, then **`Space z c`**.
4. Exit that scrollback editor with `:q!` (do not save it).
5. Switch to the actual source-code Neovim pane. Position the cursor and press **`Space z p`**. The copied lines are inserted below the current line.

For ordinary selectable Zellij output, a mouse selection can invoke your configured `copy_command` too. Mouse support in kmscon may differ, so the editor method is the dependable keyboard-only fallback.

### D. Neovim → terminal-chat

1. Select code with `V` and movement in the source Neovim, then `Space z c`.
2. Switch to the chat pane, focus its **input field**.
3. Press **`Ctrl+g → p → v`** to paste into the focused pane. **OR** press `Space z s` from Neovim and enter its `terminal_N` ID to send without changing focus.
4. Review the pasted text before submitting it to the chat program.

### E. One terminal pane → another (including other tabs)

After Zellij copies terminal text into the file, simply switch to the destination pane and press **`Ctrl+g → p → v`**. Zellij IDs are **session-wide**, so `terminal_3` can be in a different tab. If you need explicit targeting from a separate shell pane:

```bash
zellij action list-panes
zpaste terminal_3
```

For direct shell-generated content without manual highlighting:

```bash
some_safe_command > /tmp/report.txt
~/.local/bin/zellij-copy-file < /tmp/report.txt
# Switch to target pane, Ctrl+g → p → v
```

To examine the current transfer:

```bash
cat ~/.cache/zellij-clipboard.txt
```

**Safety and fidelity:** The clipboard file persists until overwritten; do not store secrets in it. The paste helper uses command substitution, which removes **trailing** newline characters, although internal line breaks are preserved. Bracketed paste does not make all target shells/programs safe: multiline input at a live Bash prompt may run commands. Review commands before sending them. For insertion into source code, `Space z p` is safer than sending raw keystrokes.

**Not universal across hosts:** Primary and Minddump have separate `$HOME/.cache/` files. This setup transfers within one machine/session; remote-to-local copying will need a deliberate SSH bridge later if you want it.

## 10. Diagnosis: where to look when something fails

| Command | Use |
| --- | --- |
| `:messages` | Recently displayed Neovim errors |
| `:checkhealth` | Full health report |
| `:checkhealth vim.lsp` | LSP attachments and warnings for open buffer |
| `:lua vim.print(vim.lsp.get_clients({bufnr=0}))` | Exact attached clients for buffer |
| `:Mason` | Installed and missing editor tools |
| `:ConformInfo` | Formatter status (press `q` to close) |
| `:set filetype?` | Verify filetype detection (`htmldjango`, `python`, etc.) |
| `:set clipboard?` | Should be empty inside Zellij (by design) |
| `:pwd` | Current editor working directory |
| `:Telescope keymaps` | Search mapping descriptions |
| `:verbose nmap <C-h>` | See who last defined a mapping |
| `:lua vim.pack.update(nil, { offline = true })` | Inspect plugin state without fetching |
| `:lua vim.pack.update()` | Update plugins **intentionally**, after backup |

The `:LspInfo` command from older Neovim versions **does not exist** in this setup. A `vim.lsp` health warning about extra YAML filetypes (`yaml.docker-compose`, etc.) can be informational when the actual filetype/server tests work. Only Python/Django actual completion, formatter, and runtime tests prove the tools work.

**NVM/Tree-sitter after an old login session:** Node and `tree-sitter` were installed under NVM. If Neovim says the command is missing even though it worked over SSH, log out and back in to refresh the shell or load NVM in that shell. Do not reinstall a healthy binary unnecessarily.

**Temporary health buffers and info windows:** `q` or `:close` often closes the focused information window; `Esc` merely exits Insert/other modes, it does not close windows.

**Filetype names and language servers**: `:set filetype?` and the `Active Clients` section of `:checkhealth vim.lsp` are the useful checks. No attached server on an empty `[No Name]` buffer is normal.

## 11. Files and dependencies to preserve before Minddump synchronization

### Configuration files **present in the archive**

```text
~/.config/nvim/init.lua
~/.config/nvim/htmx.html-data.json
~/.config/nvim/lua/custom/python_debug.lua
~/.config/nvim/lua/custom/zellij_navigation.lua
~/.config/nvim/lua/kickstart/plugins/neo-tree.lua
~/.config/nvim/nvim-pack-lock.json
~/.config/zellij/config.kdl
~/.local/bin/zellij-copy-file
~/.local/bin/zellij-paste-focused
~/.local/bin/zpaste
```

`~/.config/nvim` also contains upstream Kickstart modules, documentation and a `.stylua.toml`. The Git repository should include custom configs and the lockfile; scripts must remain **executable**. It should *not* include private clipboard content, temporary files, or old backup configs.

### Dependencies **not copied** by a config-only Git clone

- Neovim 0.12.6, Zellij **0.46**, Git, GCC/Make, ripgrep, `fd`/`fdfind`, Node/npm under NVM, and Tree-sitter CLI.
- Python provider (`pynvim` via pipx) and Node Neovim provider (npm package) if desired.
- Mason-installed language servers and tools (installed on each host), plus `djlint` and `djls` installed independently with pipx.
- `debugpy` adapter venv at `~/.local/share/nvim/debugpy-venv/`.
- The automatic `terminal_N` pane renaming lives in your **`.bashrc`**, which was **not included in this archive**. Carry it over or adapt separately; don't overwrite Minddump's full `.bashrc` blindly.
- Nerd Font rendering requires a capable **display terminal**; kmscon on Primary was set up for this. When SSH'd into Minddump, the local terminal draws the glyphs.

### Static audit findings (before publishing to Git)

1. **Lockfile is excluded by upstream `.gitignore`**: remove `nvim-pack-lock.json` from `.gitignore` or force-add it intentionally before pushing, so both hosts can reproduce the same plugin revisions.
2. **Old backups were included**: `init.lua.pre-*` files should be excluded from the repo. Preserve them privately as you wish.
3. **HTML custom-data handler robustness**: if the HTMX data file becomes unreadable, `pcall(vim.fn.readfile, path)` failure currently returns `nil`; returning `''` is safer for this LSP request handler. The working happy path is already tested.
4. **Bash pane-naming code wasn't archived**: we cannot audit or synchronize that portion from these files alone.

These are portability/robustness items, not evidence the running installation is broken. The uploaded archive is a **static snapshot**, not a live runtime test or proof of installed external packages.

## 12. Suggested everyday layout

```text
PRIMARY / kmscon / Zellij
+-----------------------------+------------------------------+
| terminal_1: Neovim          | terminal_2: chat client      |
| views.py / forms.py         | Copy examples to shared file|
+-----------------------------+------------------------------+
| terminal_3: project shell, tests, git, docker logs           |
+------------------------------------------------------------+
```

**Quick work cycle:** `Space s f` to open file → `grd` to inspect → `Space f` when needed → `Space d b` to debug standalone Python → `Space z c` to share code → focus chat pane → `Ctrl+g p v` paste → copy response via `Ctrl+g s e` → `Space z c` → `Space z p` into code.

For the **work Django application** after Minddump is configured, add the Docker-specific debugger attach profile as a separate later change. Do not assume the existing standalone-Python debug profile can attach to a container.

---

**Companion:** `neovim_zellij_quick_reference.txt` — compact, monospace-friendly commands for use with `less` in a Linux TTY.
