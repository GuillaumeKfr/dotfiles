-- Catppuccin colorscheme. Loaded after init.lua's default tokyonight, so it
-- takes over as the active colorscheme.
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'catppuccin/nvim' }

require('catppuccin').setup {
  transparent_background = true,
}

vim.cmd.colorscheme 'catppuccin-mocha'

-- Configure highlights.
vim.cmd.hi 'Comment gui=none'
