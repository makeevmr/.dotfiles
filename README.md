# Configuration files
Manage dotfiles with [stow](https://dev.to/crafts69guy/how-to-manage-your-dotfiles-like-a-pro-with-git-and-stow-3pg1)  

Clone project to home directory:
```bash
cd ~
git clone git@github.com:makeevmr/.dotfiles.git
```

## Program installation
Install programs with `./install.sh <program_name_1> <program_name_2> ...`

Available programs:
- alacritty
- nvim
- sway
- tmux
- zsh

Example: `./install.sh alacritty zsh`