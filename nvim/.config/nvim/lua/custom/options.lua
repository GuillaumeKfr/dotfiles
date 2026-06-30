-- Personal option overrides and keymaps.
-- Loaded from custom/init.lua so they survive upstream subtree updates.

-- Relative line numbers, to help with jumping.
vim.o.relativenumber = true

-- Leave insert mode without reaching for <Esc>.
vim.keymap.set('i', 'jj', '<Esc>', { noremap = true, desc = 'Leave insert mode' })

-- Diagnostic keymaps.
vim.keymap.set('n', '(d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ')d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
