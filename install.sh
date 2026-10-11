#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Installer: Arch Linux, Hyprland, Waybar, SDDM & Neovim Suite
# Author: Uttam Mahata
# ==============================================================================

set -euo pipefail

# ANSI color codes
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
RED="\033[0;31m"
RESET="\033[0m"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
INSTALL_METHOD="link"  # "link" (symlink) or "copy"

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
    echo "       /\     ____   _____ _    _   _      _____ _   _ _    ___   __"
    echo "      /  \   |  _ \ / ____| |  | | | |    |_   _| \ | | |  | \ \ / /"
    echo "     / /\ \  | |_) | |    | |__| | | |      | | |  \| | |  | |\ V / "
    echo "    / ____ \ |  _ <| |    |  __  | | |      | | | . \` | |  | | > <  "
    echo "   /_/    \_\|_| \_\\_____|_|  |_| |______|_____|_|\_|\____/ /_/ \_\ "
    echo -e "${RESET}"
    echo -e "${BOLD}Hyprland • Waybar • SDDM • Hyprlock • Kitty • Neovim Dotfiles${RESET}"
    echo "------------------------------------------------------------------"
}

backup_target() {
    local target="$1"
    if [ -L "$target" ]; then
        local current_dest
        current_dest="$(readlink "$target" || true)"
        if [ "$current_dest" = "$2" ]; then
            return 1 # Already correctly linked
        fi
        log_warn "Replacing existing symlink $target -> $current_dest"
        rm -f "$target"
        return 0
    elif [ -e "$target" ]; then
        log_warn "Existing $target detected. Backing up to ${target}.bak.${TIMESTAMP}"
        mv "$target" "${target}.bak.${TIMESTAMP}"
        return 0
    fi
    return 0
}

install_entry() {
    local src="$1"
    local dest="$2"
    local parent_dir
    parent_dir="$(dirname "$dest")"
    mkdir -p "$parent_dir"

    if backup_target "$dest" "$src"; then
        if [ "$INSTALL_METHOD" = "link" ]; then
            ln -sf "$src" "$dest"
            log_success "Symlinked $dest -> $src"
        else
            cp -r "$src" "$dest"
            log_success "Copied $src -> $dest"
        fi
    else
        log_info "$dest is already correctly linked to $src"
    fi
}

setup_vim() {
    log_info "Configuring classic Vim..."
    mkdir -p "$HOME/.vim" "$HOME/.vim/undodir"
    install_entry "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"

    if [ -f "$DOTFILES_DIR/vim/coc-settings.json" ]; then
        install_entry "$DOTFILES_DIR/vim/coc-settings.json" "$HOME/.vim/coc-settings.json"
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

    # Headless plugin install
    if command -v vim >/dev/null 2>&1; then
        log_info "Installing Vim plugins via vim-plug..."
        vim +PlugInstall +qa || true
        log_success "Vim plugins configured."
    fi
}

setup_nvim() {
    log_info "Configuring Neovim (LazyVim)..."
    install_entry "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

    if command -v nvim >/dev/null 2>&1; then
        log_info "Neovim detected ($(nvim --version | head -n 1))."
        log_info "Plugins will be initialized by Lazy.nvim upon launch."
    else
        log_warn "nvim command not found. Install Neovim 0.10+ to use this config."
    fi
}

setup_hypr() {
    log_info "Configuring Hyprland, Hyprlock, Hypridle & Hyprpaper..."
    mkdir -p "$HOME/.config/hypr/scripts"

    install_entry "$DOTFILES_DIR/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
    install_entry "$DOTFILES_DIR/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
    install_entry "$DOTFILES_DIR/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
    install_entry "$DOTFILES_DIR/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
    install_entry "$DOTFILES_DIR/hypr/scripts/monitor-sync.sh" "$HOME/.config/hypr/scripts/monitor-sync.sh"
    chmod +x "$HOME/.config/hypr/scripts/monitor-sync.sh" 2>/dev/null || true

    log_success "Hyprland suite configured."
}

setup_waybar() {
    log_info "Configuring Waybar..."
    mkdir -p "$HOME/.config/waybar/scripts"

    install_entry "$DOTFILES_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
    install_entry "$DOTFILES_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"

    for script in "$DOTFILES_DIR"/waybar/scripts/*; do
        if [ -f "$script" ]; then
            local sname
            sname="$(basename "$script")"
            install_entry "$script" "$HOME/.config/waybar/scripts/$sname"
            chmod +x "$HOME/.config/waybar/scripts/$sname" 2>/dev/null || true
        fi
    done

    log_success "Waybar configured."
}

setup_kitty() {
    log_info "Configuring Kitty..."
    mkdir -p "$HOME/.config/kitty"
    install_entry "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    log_success "Kitty terminal configured."
}

setup_wofi() {
    log_info "Configuring Wofi..."
    mkdir -p "$HOME/.config/wofi"
    install_entry "$DOTFILES_DIR/wofi/config" "$HOME/.config/wofi/config"
    install_entry "$DOTFILES_DIR/wofi/style.css" "$HOME/.config/wofi/style.css"
    log_success "Wofi launcher configured."
}

setup_scripts() {
    log_info "Installing desktop helper scripts to ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"

    install_entry "$DOTFILES_DIR/scripts/display-mode" "$HOME/.local/bin/display-mode"
    chmod +x "$HOME/.local/bin/display-mode" 2>/dev/null || true

    install_entry "$DOTFILES_DIR/scripts/new-workspace" "$HOME/.local/bin/new-workspace"
    chmod +x "$HOME/.local/bin/new-workspace" 2>/dev/null || true

    install_entry "$DOTFILES_DIR/scripts/daily-wallpaper" "$HOME/.local/bin/daily-wallpaper"
    chmod +x "$HOME/.local/bin/daily-wallpaper" 2>/dev/null || true

    if [ -d "$DOTFILES_DIR/systemd/user" ]; then
        mkdir -p "$HOME/.config/systemd/user"
        install_entry "$DOTFILES_DIR/systemd/user/daily-wallpaper.service" "$HOME/.config/systemd/user/daily-wallpaper.service"
        install_entry "$DOTFILES_DIR/systemd/user/daily-wallpaper.timer" "$HOME/.config/systemd/user/daily-wallpaper.timer"
        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user daemon-reload 2>/dev/null || true
            systemctl --user enable --now daily-wallpaper.timer 2>/dev/null || true
        fi
    fi

    log_success "Desktop scripts installed to ~/.local/bin and daily-wallpaper timer enabled."
}

setup_wallpapers() {
    log_info "Installing wallpapers to ~/Pictures/Wallpapers..."
    mkdir -p "$HOME/Pictures/Wallpapers"

    for wp in "$DOTFILES_DIR"/wallpapers/*.jpg "$DOTFILES_DIR"/wallpapers/*.png; do
        if [ -f "$wp" ]; then
            local fname
            fname="$(basename "$wp")"
            install_entry "$wp" "$HOME/Pictures/Wallpapers/$fname"
        fi
    done
    log_success "Wallpapers installed."
}

setup_sddm() {
    log_info "Installing SDDM Arch Slate theme..."
    if [ -f "$DOTFILES_DIR/scripts/install-sddm.sh" ]; then
        bash "$DOTFILES_DIR/scripts/install-sddm.sh"
    else
        log_error "SDDM installer script not found at $DOTFILES_DIR/scripts/install-sddm.sh"
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Component Options:"
    echo "  --all         Install complete dotfiles suite (Desktop + Neovim + Vim)"
    echo "  --desktop     Install all desktop components (Hyprland, Waybar, Kitty, Wofi, Scripts, Wallpapers)"
    echo "  --hypr        Install Hyprland, Hyprlock, Hypridle, and Hyprpaper"
    echo "  --waybar      Install Waybar status bar and helper scripts"
    echo "  --kitty       Install Kitty terminal configuration"
    echo "  --wofi        Install Wofi application launcher"
    echo "  --scripts     Install display-mode and new-workspace to ~/.local/bin"
    echo "  --wallpapers  Install wallpapers to ~/Pictures/Wallpapers"
    echo "  --sddm        Install SDDM Arch Slate theme (requires sudo)"
    echo "  --nvim        Install Neovim (LazyVim) configuration"
    echo "  --vim         Install classic Vim configuration"
    echo ""
    echo "Installation Methods:"
    echo "  --link        Use symlinks (Default: modifications reflect immediately)"
    echo "  --copy        Copy files instead of symlinking"
    echo "  -h, --help    Show this help message"
    echo ""
    exit 0
}

main() {
    print_banner

    local TARGETS=()

    while [ $# -gt 0 ]; do
        case "$1" in
            --link)
                INSTALL_METHOD="link"
                shift
                ;;
            --copy)
                INSTALL_METHOD="copy"
                shift
                ;;
            --all|--desktop|--hypr|--waybar|--kitty|--wofi|--scripts|--wallpapers|--sddm|--nvim|--vim)
                TARGETS+=("${1#--}")
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done

    # Default to desktop + vim + nvim if no targets specified
    if [ ${#TARGETS[@]} -eq 0 ]; then
        TARGETS=("desktop" "vim" "nvim")
    fi

    log_info "Install method: ${BOLD}${INSTALL_METHOD}${RESET}"

    for target in "${TARGETS[@]}"; do
        case "$target" in
            all)
                setup_wallpapers
                setup_scripts
                setup_kitty
                setup_wofi
                setup_hypr
                setup_waybar
                setup_vim
                setup_nvim
                echo ""
                log_info "To install the system-wide SDDM theme, run: ./install.sh --sddm"
                ;;
            desktop)
                setup_wallpapers
                setup_scripts
                setup_kitty
                setup_wofi
                setup_hypr
                setup_waybar
                ;;
            hypr)
                setup_hypr
                ;;
            waybar)
                setup_waybar
                ;;
            kitty)
                setup_kitty
                ;;
            wofi)
                setup_wofi
                ;;
            scripts)
                setup_scripts
                ;;
            wallpapers)
                setup_wallpapers
                ;;
            sddm)
                setup_sddm
                ;;
            vim)
                setup_vim
                ;;
            nvim)
                setup_nvim
                ;;
        esac
    done

    echo ""
    echo -e "${GREEN}${BOLD}Configuration Complete!${RESET}"
    echo -e "Reload shortcuts:"
    echo -e "  • Hyprland:   ${CYAN}hyprctl reload${RESET}"
    echo -e "  • Waybar:     ${CYAN}killall -SIGUSR2 waybar${RESET}"
    echo -e "  • Hyprlock:   ${CYAN}hyprlock${RESET}"
    echo -e "  • SDDM Test:  ${CYAN}$DOTFILES_DIR/scripts/test-sddm.sh${RESET}"
    echo ""
}

main "$@"
