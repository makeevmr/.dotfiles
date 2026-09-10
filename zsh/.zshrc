# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gallois"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Tokyo Night accents for shell plugins; the Gallois prompt uses Alacritty ANSI colors.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
ZSH_HIGHLIGHT_STYLES[comment]="fg=#565f89"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=#f7768e"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=#bb9af7"
ZSH_HIGHLIGHT_STYLES[command]="fg=#7dcfff"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#7aa2f7"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#7dcfff"
ZSH_HIGHLIGHT_STYLES[path]="fg=#9ece6a,underline"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=#9ece6a"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=#9ece6a"

# Update automatically without asking
zstyle ':omz:update' mode auto

# Aliases
alias set_keybright='sudo brightnessctl -d tpacpi::kbd_backlight set'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export EDITOR="/usr/local/bin/nvim"

eval $(skotty ssh env)
