require("nvim-tree").setup({
    sort_by = "case_sensitive",
    actions = {
        open_file = { quit_on_open = true }
    },
    view = {
        adaptive_size = true,
        mappings = {
            list = {
                { key = "u", action = "dir_up" },
            },
        },
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
        custom = { '^.git$', '^node_modules$' }
    },
})
