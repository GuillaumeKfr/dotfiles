local vim = vim
-- Globals
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Move lines around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Delete without putting into buffer
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Esc = Ctrl-C
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Easy replace word
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Split window
vim.keymap.set("n", "<A-L>", vim.cmd.vsplit)
vim.keymap.set("n", "<A-J>", vim.cmd.split)

-- Split navigation
vim.keymap.set("n", "<A-j>", "<C-W><c-J>")
vim.keymap.set("n", "<A-k>", "<C-W><C-K>")
vim.keymap.set("n", "<A-l>", "<C-W><C-L>")
vim.keymap.set("n", "<A-h>", "<C-W><C-H>")

-- Telescope
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- Fugitive
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

-- Harpoon
vim.keymap.set("n", "<leader>a", require('harpoon.mark').add_file)
vim.keymap.set("n", "<C-e>", require('harpoon.ui').toggle_quick_menu)

vim.keymap.set("n", "<C-h>", function() require('harpoon.ui').nav_file(1) end)
vim.keymap.set("n", "<C-j>", function() require('harpoon.ui').nav_file(2) end)
vim.keymap.set("n", "<C-k>", function() require('harpoon.ui').nav_file(3) end)
vim.keymap.set("n", "<C-l>", function() require('harpoon.ui').nav_file(4) end)
