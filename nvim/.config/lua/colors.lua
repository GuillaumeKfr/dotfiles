require("catppuccin").setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    no_italic = true,
})

vim.cmd.colorscheme "catppuccin"

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
