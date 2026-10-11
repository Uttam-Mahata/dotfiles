#!/usr/bin/env bash
# ==============================================================================
# Install and activate the Arch Slate SDDM theme system-wide.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
THEME_SRC="$DOTFILES_DIR/sddm/themes/arch-slate"
TARGET_DIR="/usr/share/sddm/themes/arch-slate"

if [ ! -d "$THEME_SRC" ]; then
    echo "Error: SDDM theme source directory not found at $THEME_SRC" >&2
    exit 1
fi

echo "==> Ensuring required dependencies are installed..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --needed --noconfirm qt6-declarative qt6-svg qt5-quickcontrols2
fi

echo "==> Installing SDDM theme to $TARGET_DIR..."
sudo mkdir -p "$TARGET_DIR"
sudo cp -r "$THEME_SRC/"* "$TARGET_DIR/"
sudo chmod 644 "$TARGET_DIR"/*
sudo chmod 755 "$TARGET_DIR"

echo "==> Configuring SDDM to use arch-slate theme..."
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/arch-slate.conf > /dev/null << 'EOF'
[Theme]
Current=arch-slate
EOF

echo "==> Done! Theme installed and active: arch-slate"
echo "You can test the installed theme in a preview window using:"
echo "    $SCRIPT_DIR/test-sddm.sh"
