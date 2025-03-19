## Installation

To install, run the `install_env.sh` script.

### Neovim

Neovim's config is managed in a separate repo, declared here as a submodule.

To init the repo with the config:

`git submodule update --init --recursive`

To update the repo with the latest version:

`git submodule foreach git pull --ff-only origin master`

### GitConfig

Create a `~/.gitconfig_custom` file with content:

```
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

Create the files `~/path/to/first/.gitconfig`, `~/path/to/second/.gitconfig` as appropiate for each custom config:

```
[user]
name = "<Name>"
email = "<email_address>"

[core]
sshCommand = ssh -i ~/.ssh/<main_pub_key>
```

## Credits

NeoVim config: (kickstart.nvim)[https://github.com/nvim-lua/kickstart.nvim]

