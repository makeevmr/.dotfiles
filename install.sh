#!/bin/bash

set -euo pipefail

sudo apt update

if ! command -v git >/dev/null; then
    sudo apt install -y git
fi

if ! command -v stow >/dev/null; then
    sudo apt install stow -y
fi

cd ~
stow -d ~ -t ~/.config .dotfiles

install_alacritty() {
    echo "Installing alacritty..."
    sudo add-apt-repository ppa:aslatter/ppa -y
    sudo apt install alacritty -y
}

install_nvim() {
    echo "Installing nvim..."
    sudo snap install nvim --classic
}

install_sway() {
    echo "Installing sway..."
    sudo apt install fuzzel gtklock sway waybar
}

install_tmux() {
    echo "Installing tmux..."
    sudo apt install -y tmux
}

install_zsh() {
    echo "Installing zsh..."

    sudo apt install -y zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        chsh -s "$(which zsh)"
    fi
    printf '%s\n' \
      'export ZDOTDIR="$HOME/.config/zsh"' \
      'export PATH="$HOME/.local/bin:$PATH"' \
      > ~/.zshenv

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Plugins
    plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

    # zsh-syntax-highlighting
    if [[ ! -d "$plugin_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$plugin_dir/zsh-syntax-highlighting"
    fi

    # zsh-autosuggestions
    if [[ ! -d "$plugin_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$plugin_dir/zsh-autosuggestions"
    fi

    # For arc support check out https://github.com/misbiheyv/arc-zsh-plugin

    rm ~/.zshrc
}

declare -A installers=(
    [alacritty]=install_alacritty
    [nvim]=install_nvim
    [sway]=install_sway
    [tmux]=install_tmux
    [zsh]=install_zsh
)

for component in "$@"; do
    if [[ -v installers[$component] ]]; then
        "${installers[$component]}"
    else
        echo "Unknown component: $component"
        exit 1
    fi
done
