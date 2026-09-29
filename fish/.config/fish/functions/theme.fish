# Global color theme switcher (Catppuccin <-> Rosé Pine).
# Usage: theme catppuccin | theme rosepine | theme (prints current)

function theme
    set -l state_dir ~/.config/theme
    set -l state_file $state_dir/current

    if test (count $argv) -eq 0
        cat $state_file 2>/dev/null; or echo catppuccin
        return
    end

    set -l name $argv[1]
    if test "$name" != catppuccin -a "$name" != rosepine
        echo "theme: unknown theme '$name' (expected: catppuccin, rosepine)" >&2
        return 1
    end

    command mkdir -p $state_dir
    echo $name > $state_file

    # kitty (live reload; kitty already bundles both themes)
    if test "$name" = rosepine
        kitty +kitten themes --reload-in=all "Rosé Pine" >/dev/null
    else
        kitty +kitten themes --reload-in=all "Catppuccin-Mocha" >/dev/null
    end

    # tmux (live reload)
    cp ~/.config/tmux/themes/$name.conf ~/.config/tmux/theme.conf
    if type -q tmux; and tmux info >/dev/null 2>&1
        tmux source-file ~/.config/tmux/tmux.conf
    end

    # btop (applies on next launch)
    if test -f ~/.config/btop/btop.conf
        if test "$name" = rosepine
            sed -i '' 's/^color_theme = .*/color_theme = "rose_pine"/' ~/.config/btop/btop.conf
        else
            sed -i '' 's/^color_theme = .*/color_theme = "catppuccin_mocha"/' ~/.config/btop/btop.conf
        end
    end

    # lazygit (applies on next launch): splice the block between the
    # "# theme:start" / "# theme:end" markers in config.yml
    set -l lg ~/.config/lazygit/config.yml
    if test -f $lg
        set -l block ~/.config/lazygit/themes/$name.yml
        awk -v blockfile=$block '
            /# theme:start/ { print; while ((getline l < blockfile) > 0) print l; skip=1; next }
            /# theme:end/ { skip=0 }
            skip { next }
            { print }
        ' $lg > $lg.tmp && mv $lg.tmp $lg
    end

    echo "theme: switched to $name (nvim needs a restart, new shells pick up fzf colors)"
end
