-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
      require('oil').setup {
        view_options = { show_hidden = true },
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
        },
      }
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = '[-] Open parent directory' })
    end,
  },
}
