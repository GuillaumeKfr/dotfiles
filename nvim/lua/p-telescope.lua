require('telescope').setup(){
    defaults={
        file_ignore_patterns = {
            "node_modules", ".git", "build", "dist"
        }
    },
    pickers = {
        find_files = {
            additional_args = function(_)
                return {"--hidden"}
            end
        },
        live_grep = {
            additional_args = function(_)
                return {"--hidden"}
            end
        },
    },
}
