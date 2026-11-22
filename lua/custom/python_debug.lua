-- ============================================================
-- Python Debugging
-- nvim-dap + nvim-dap-ui + debugpy
-- ============================================================

-- Install debugging plugins.
vim.pack.add({
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
})

local dap = require('dap')
local dapui = require('dapui')

-- Configure debugging interface.
dapui.setup()

-- Automatically open debugging panels.
dap.listeners.after.event_initialized['dapui_config'] =
  function()
    dapui.open()
  end

-- ============================================================
-- Python Debug Adapter
-- ============================================================

dap.adapters.python = {
  type = 'executable',

  command = vim.fn.expand(
    '~/.local/share/nvim/debugpy-venv/bin/python'
  ),

  args = { '-m', 'debugpy.adapter' },
}

-- ============================================================
-- Python Debug Configurations
-- ============================================================

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Debug current Python file',

    program = '${file}',

    console = 'integratedTerminal',

    justMyCode = true,

    -- Use the project's Python environment when available.
    pythonPath = function()

      local venv = vim.env.VIRTUAL_ENV

      if venv then
        local python = venv .. '/bin/python'

        if vim.fn.executable(python) == 1 then
          return python
        end
      end

      local cwd = vim.fn.getcwd()

      for _, directory in ipairs({
        '.venv',
        'venv',
      }) do

        local python = cwd .. '/' ..
          directory .. '/bin/python'

        if vim.fn.executable(python) == 1 then
          return python
        end

      end

      return vim.fn.exepath('python3')

    end,
  },
}

-- ============================================================
-- Debugging Keyboard Shortcuts
-- ============================================================

vim.keymap.set('n', '<leader>db', function()
  dap.toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })

vim.keymap.set('n', '<leader>dc', function()
  dap.continue()
end, { desc = 'Debug: Start/Continue' })

vim.keymap.set('n', '<leader>dn', function()
  dap.step_over()
end, { desc = 'Debug: Step Over' })

vim.keymap.set('n', '<leader>di', function()
  dap.step_into()
end, { desc = 'Debug: Step Into' })

vim.keymap.set('n', '<leader>do', function()
  dap.step_out()
end, { desc = 'Debug: Step Out' })

vim.keymap.set('n', '<leader>du', function()
  dapui.toggle()
end, { desc = 'Debug: Toggle UI' })

vim.keymap.set('n', '<leader>dx', function()
  dap.terminate()
end, { desc = 'Debug: Terminate' })
