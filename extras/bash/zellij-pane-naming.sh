# Managed Zellij pane naming, sourced from ~/.bashrc for interactive Bash shells.
# The pane ID is a number. Zellij identifies terminal panes as terminal_N.

__zellij_name_pane_once() {
  [[ -n "${ZELLIJ:-}" ]] || return 0
  [[ "${ZELLIJ_PANE_ID:-}" =~ ^[0-9]+$ ]] || return 0
  [[ "${__ZELLIJ_PANE_RENAMED:-}" != "$ZELLIJ_PANE_ID" ]] || return 0

  local pane_name="terminal_${ZELLIJ_PANE_ID}"
  if command -v zellij >/dev/null 2>&1 &&
     zellij action rename-pane --pane-id "$pane_name" "$pane_name" >/dev/null 2>&1; then
    __ZELLIJ_PANE_RENAMED="$ZELLIJ_PANE_ID"
  fi
}

# Do not add the hook twice if the old inline ~/.bashrc block is still present.
if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null || true)" == "declare -a "* ]]; then
  __zellij_has_pane_hook=0
  for __zellij_item in "${PROMPT_COMMAND[@]}"; do
    if [[ "$__zellij_item" == *__zellij_name_pane_once* ]]; then
      __zellij_has_pane_hook=1
      break
    fi
  done
  if (( ! __zellij_has_pane_hook )); then
    PROMPT_COMMAND+=(__zellij_name_pane_once)
  fi
  unset __zellij_item __zellij_has_pane_hook
else
  if [[ "${PROMPT_COMMAND:-}" != *__zellij_name_pane_once* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__zellij_name_pane_once"
  fi
fi
