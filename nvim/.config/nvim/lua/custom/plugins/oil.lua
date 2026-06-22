-- File explorer that lets you edit your filesystem like a buffer.
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'stevearc/oil.nvim',
  gh 'nvim-tree/nvim-web-devicons',
}

require('oil').setup {
  view_options = { show_hidden = true },
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
  },
}

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = '[-] Open parent directory' })
