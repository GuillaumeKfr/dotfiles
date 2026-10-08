-- Claude Code IDE integration. Claude runs in the workmux tmux pane; run `/ide` there to connect.
vim.pack.add { 'https://github.com/coder/claudecode.nvim' }

require('claudecode').setup {
  terminal = { provider = 'none' },
}

-- Jump to the Claude pane (right of nvim in the workmux layout) after a send.
vim.api.nvim_create_autocmd('User', {
  pattern = 'ClaudeCodeSendComplete',
  callback = function()
    if vim.env.TMUX_PANE then vim.system { 'tmux', 'select-pane', '-t', vim.env.TMUX_PANE, '-R' } end
  end,
})

vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = '[A]I [S]end selection to Claude' })
vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = '[A]I add current [B]uffer to Claude' })
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = '[A]I [A]ccept diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = '[A]I [D]eny diff' })
