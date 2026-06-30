-- Seamlessly navigate between tmux panes and Neovim splits with <C-h/j/k/l>.
vim.pack.add { 'https://github.com/christoomey/vim-tmux-navigator' }

-- Override the default window-only navigation keymaps so they also move
-- across tmux panes.
vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { desc = 'Move focus to the left window/pane' })
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { desc = 'Move focus to the lower window/pane' })
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { desc = 'Move focus to the upper window/pane' })
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { desc = 'Move focus to the right window/pane' })
