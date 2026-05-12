# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH="$PATH:$HOME/.local/bin"

ZSH_THEME="gallois"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Update automatically without asking
zstyle ':omz:update' mode auto

# Aliases
alias set_keybright='sudo brightnessctl -d tpacpi::kbd_backlight set'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
