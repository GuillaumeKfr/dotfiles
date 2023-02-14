require('telescope').setup {
    defaults={
        file_ignore_patterns = {
            "node_modules", ".git/", "build", "dist"
        },
    },
    pickers = {
        find_files = {
            hidden = true,
            theme = 'dropdown',
        },
        live_grep = {
            hidden = true,
            theme = "dropdown",
        },
        diagnostics = {
            theme = "dropdown"
        }
    },
}
