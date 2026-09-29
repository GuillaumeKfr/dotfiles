-- Loaded after init.lua's default tokyonight, so it takes over as the active
-- colorscheme. Reads ~/.config/theme/current (written by the `theme` fish
-- function) to pick which colorscheme plugin to load.
local f = io.open(vim.fn.expand '~/.config/theme/current', 'r')
local theme = f and f:read '*l' or 'catppuccin'
if f then
  f:close()
end

if theme == 'rosepine' then
  vim.pack.add { 'https://github.com/rose-pine/neovim' }
  require('rose-pine').setup()
  vim.cmd.colorscheme 'rose-pine'
else
  vim.pack.add { 'https://github.com/catppuccin/nvim' }
  require('catppuccin').setup {
    transparent_background = true,
  }
  vim.cmd.colorscheme 'catppuccin-mocha'
end

-- Configure highlights.
vim.cmd.hi 'Comment gui=none'
