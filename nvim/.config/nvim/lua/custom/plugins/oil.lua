-- File explorer that lets you edit your filesystem like a buffer.
vim.pack.add {
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}

require('oil').setup {
  view_options = { show_hidden = true },
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
  },
}

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = '[-] Open parent directory' })
