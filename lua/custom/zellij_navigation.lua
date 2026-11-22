-- ============================================================
-- Neovim / Zellij Navigation
-- ============================================================

vim.pack.add({
  'https://github.com/swaits/zellij-nav.nvim',
})

local nav = require('zellij-nav')

nav.setup({})

-- Navigate between Neovim windows.
-- At the edge, switch to the adjacent Zellij pane.

vim.keymap.set('n', '<C-h>', nav.left, {
  desc = 'Navigate Left (Neovim/Zellij)',
})

vim.keymap.set('n', '<C-j>', nav.down, {
  desc = 'Navigate Down (Neovim/Zellij)',
})

vim.keymap.set('n', '<C-k>', nav.up, {
  desc = 'Navigate Up (Neovim/Zellij)',
})

vim.keymap.set('n', '<C-l>', nav.right, {
  desc = 'Navigate Right (Neovim/Zellij)',
})
