# Dotfiles

## Installation

Run `./install_env.sh` to perform a full install (same as `./install_env.sh all`).

You can also run individual steps, for example `./install_env.sh brew`
or `./install_env.sh stow`. See `./install_env.sh help` for all commands.

### Neovim

Config based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim),
managed as a git subtree. To pull upstream updates:

```bash
git subtree pull --prefix=nvim/.config/nvim \
  https://github.com/nvim-lua/kickstart.nvim.git master --squash
```

### GitConfig

Create a `~/.gitconfig_custom` file with content:

```ini
[user]
name = "<Name>"
email = "<email_address>"

[core]
sshCommand = ssh -i ~/.ssh/<main_pub_key>

[includeIf "gitdir:~/path/to/first/"]
path = ~/path/to/first/.gitconfig

[includeIf "gitdir:~/path/to/second/"]
path = ~/path/to/second/.gitconfig
```

Create the files `~/path/to/first/.gitconfig`,
`~/path/to/second/.gitconfig` as appropriate for each custom config:

```ini
[user]
name = "<Name>"
email = "<email_address>"

[core]
sshCommand = ssh -i ~/.ssh/<main_pub_key>
```

## Credits

Neovim config based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

### Open-source projects used

#### Desktop Apps

| Project | Description |
| --- | --- |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | Tiling window manager for macOS |
| [Kitty](https://github.com/kovidgoyal/kitty) | GPU-accelerated terminal emulator |

#### CLI Tools

| Project | Description |
| --- | --- |
| [bat](https://github.com/sharkdp/bat) | Cat clone with syntax highlighting |
| [btop](https://github.com/aristocratos/btop) | Resource monitor |
| [Colima](https://github.com/abiosoft/colima) | Container runtime for macOS |
| [delta](https://github.com/dandavid0/delta) | Git diff viewer |
| [direnv](https://github.com/direnv/direnv) | Directory-based env management |
| [Docker](https://github.com/docker/cli) | Container platform |
| [eza](https://github.com/eza-community/eza) | Modern ls replacement |
| [Fish](https://github.com/fish-shell/fish-shell) | User-friendly shell |
| [fzf](https://github.com/junegunn/fzf) | Command-line fuzzy finder |
| [gh](https://github.com/cli/cli) | GitHub CLI |
| [gh-dash](https://github.com/dlvhdr/gh-dash) | GitHub dashboard TUI |
| [GNU Stow](https://www.gnu.org/software/stow/) | Symlink farm manager |
| [Homebrew](https://github.com/Homebrew/brew) | Package manager for macOS/Linux |
| [jq](https://github.com/jqlang/jq) | JSON processor |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [Neovim](https://github.com/neovim/neovim) | Hyperextensible Vim-based text editor |
| [NVM](https://github.com/nvm-sh/nvm) | Node.js version manager |
| [pre-commit](https://github.com/pre-commit/pre-commit) | Git hook framework |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive grep |
| [Starship](https://github.com/starship/starship) | Cross-shell prompt |
| [tlrc](https://github.com/tldr-pages/tlrc) | tldr client in Rust |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [uv](https://github.com/astral-sh/uv) | Python package manager |
| [worktrunk](https://github.com/max-sixty/worktrunk) | Git worktree manager |
| [yazi](https://github.com/sxyazi/yazi) | Terminal file manager |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd command |
| [Zsh](https://github.com/zsh-users/zsh) | Extended Bourne shell |

#### Shell Plugins

| Project | Description |
| --- | --- |
| [Fisher](https://github.com/jorgebucaran/fisher) | Fish plugin manager |
| [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) | Zsh configuration framework |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like autosuggestions for Zsh |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Shell syntax highlighting for Zsh |
| [zsh-z](https://github.com/agkozak/zsh-z) | Directory jumping for Zsh |

#### Tmux Plugins

| Project | Description |
| --- | --- |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Automatic session saving |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf) | fzf integration for tmux |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Session save/restore |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Session manager |
| [TPM](https://github.com/tmux-plugins/tpm) | Tmux Plugin Manager |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless tmux/vim pane navigation |

#### Neovim Plugins

| Project | Description |
| --- | --- |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocompletion engine |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatter framework |
| [fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress notifications |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git gutter signs & hunk management |
| [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) | Automatic indentation detection |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP/tool installer |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Auto-install Mason tools |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | Collection of small modules |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets/quotes |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Linting framework |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configurations |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting & parsing |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File type icons |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | File explorer as a buffer |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utility library |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | Native fzf sorter for Telescope |
| [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) | UI select integration |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight TODO comments |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints |

#### Theming

| Project | Description |
| --- | --- |
| [Catppuccin](https://github.com/catppuccin/catppuccin) | Theme (Neovim, tmux, Kitty, lazygit, btop, bat) |
| [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) | Nerd Font |

#### LSP Servers & Dev Tools

| Project | Description |
| --- | --- |
| [bash-language-server](https://github.com/bash-lsp/bash-language-server) | Bash LSP |
| [lua-language-server](https://github.com/LuaLS/lua-language-server) | Lua LSP |
| [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) | Markdown linter |
| [Prettier](https://github.com/prettier/prettier) | Code formatter |
| [Pyright](https://github.com/microsoft/pyright) | Python type checker / LSP |
| [Ruff](https://github.com/astral-sh/ruff) | Python linter & formatter |
| [ShellCheck](https://github.com/koalaman/shellcheck) | Shell script analyzer |
| [shfmt](https://github.com/mvdan/sh) | Shell formatter |
| [SQLFluff](https://github.com/sqlfluff/sqlfluff) | SQL linter |
| [StyLua](https://github.com/JohnnyMorganz/StyLua) | Lua formatter |
