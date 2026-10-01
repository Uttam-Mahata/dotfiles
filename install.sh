#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Installer: High-Performance Vim & Neovim Configuration
# Author: Uttam Mahata (Gradient Geeks)
# ==============================================================================

set -euo pipefail

# ANSI color codes
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

log_info() {
    echo -e "${BLUE}${BOLD}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[WARN]${RESET} $1"
}

log_error() {
    echo -e "${RED}${BOLD}[ERROR]${RESET} $1"
}

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  __   ___  __   ___       __    "
    echo " /  \ |__  |__) |__   /\  /__\`    "
    echo " \__/ |___ |  \ |___ /~~\ .__/    "
    echo -e "${RESET}"
    echo -e "${BOLD}High-Performance Vim & Neovim Configurations${RESET}"
    echo -e "Maintained by ${CYAN}Uttam Mahata${RESET} (@gradientgeeks)"
    echo "--------------------------------------------------------"
}

setup_vim() {
    log_info "Configuring classic Vim..."

    # Backup existing ~/.vimrc
    if [ -f "$HOME/.vimrc" ] || [ -L "$HOME/.vimrc" ]; then
        log_warn "Existing ~/.vimrc detected. Backing up to ~/.vimrc.bak.${TIMESTAMP}"
        cp "$HOME/.vimrc" "$HOME/.vimrc.bak.${TIMESTAMP}"
    fi

    # Copy .vimrc
    mkdir -p "$HOME/.vim" "$HOME/.vim/undodir"
    cp "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
    log_success "Installed ~/.vimrc"

    # Copy coc-settings.json
    if [ -f "$DOTFILES_DIR/vim/coc-settings.json" ]; then
        cp "$DOTFILES_DIR/vim/coc-settings.json" "$HOME/.vim/coc-settings.json"
        log_success "Installed ~/.vim/coc-settings.json"
    fi

    # Install vim-plug if missing
    VIM_PLUG="$HOME/.vim/autoload/plug.vim"
    if [ ! -f "$VIM_PLUG" ]; then
        log_info "Installing vim-plug..."
        curl -fLo "$VIM_PLUG" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        log_success "vim-plug installed successfully."
    else
        log_info "vim-plug is already installed."
    fi

    # Install plugins headlessly
    if command -v vim >/dev/null 2>&1; then
        log_info "Installing Vim plugins via vim-plug (headless)..."
        vim +PlugInstall +qa || true
        log_success "Vim plugins installed successfully."
    else
        log_warn "vim command not found. Please install Vim to complete plugin installation."
    fi
}

setup_nvim() {
    log_info "Configuring Neovim (LazyVim)..."

    NVIM_CONFIG_DIR="$HOME/.config/nvim"

    # Backup existing ~/.config/nvim
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        log_warn "Existing ~/.config/nvim detected. Backing up to ${NVIM_CONFIG_DIR}.bak.${TIMESTAMP}"
        cp -r "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.bak.${TIMESTAMP}"
        rm -rf "$NVIM_CONFIG_DIR"
    fi

    # Copy Neovim configuration
    mkdir -p "$HOME/.config"
    cp -r "$DOTFILES_DIR/nvim" "$NVIM_CONFIG_DIR"
    log_success "Installed ~/.config/nvim"

    if command -v nvim >/dev/null 2>&1; then
        log_info "Neovim detected ($(nvim --version | head -n 1))."
        log_info "Lazy.nvim will automatically download plugins upon first launching 'nvim'."
    else
        log_warn "nvim command not found. Install Neovim 0.10+ to use this config."
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all       Install both Vim and Neovim configurations (Default)"
    echo "  --vim       Install classic Vim configuration only"
    echo "  --nvim      Install Neovim (LazyVim) configuration only"
    echo "  -h, --help  Show this help message"
    exit 0
}

main() {
    print_banner

    MODE="all"
    if [ $# -gt 0 ]; then
        case "$1" in
            --vim)
                MODE="vim"
                ;;
            --nvim)
                MODE="nvim"
                ;;
            --all)
                MODE="all"
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    fi

    case "$MODE" in
        vim)
            setup_vim
            ;;
        nvim)
            setup_nvim
            ;;
        all)
            setup_vim
            echo ""
            setup_nvim
            ;;
    esac

    echo ""
    echo -e "${GREEN}${BOLD}Setup Complete!${RESET}"
    echo -e "Launch with:"
    if [ "$MODE" != "nvim" ]; then
        echo -e "  ${CYAN}vim${RESET}   - TokyoNight theme, CoC LSP, FZF, Fugitive"
    fi
    if [ "$MODE" != "vim" ]; then
        echo -e "  ${CYAN}nvim${RESET}  - LazyVim, Mason LSP, Telescope, Neo-tree"
    fi
    echo ""
}

main "$@"
