if status is-interactive
    # fzf colors follow the theme set via the `theme` fish function
    set -l theme_name (cat ~/.config/theme/current 2>/dev/null; or echo catppuccin)
    set -gx FZF_DEFAULT_OPTS (cat ~/.config/fish/fzf-themes/$theme_name.conf)

    # Catppuccin Mocha theme for bat (no official Rosé Pine bat theme)
    set -gx BAT_THEME "Catppuccin Mocha"
end
