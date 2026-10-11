#!/usr/bin/env bash
# ==============================================================================
# Preview the Arch Slate SDDM theme in a test window without logging out.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
THEME_DIR="$DOTFILES_DIR/sddm/themes/arch-slate"

if [ ! -d "$THEME_DIR" ]; then
    echo "Error: SDDM theme directory not found at $THEME_DIR" >&2
    exit 1
fi

echo "==> Launching SDDM greeter in test mode with theme: $THEME_DIR"

if command -v sddm-greeter-qt6 &> /dev/null; then
    sddm-greeter-qt6 --test-mode --theme "$THEME_DIR"
elif command -v sddm-greeter &> /dev/null; then
    sddm-greeter --test-mode --theme "$THEME_DIR"
else
    echo "Error: Neither sddm-greeter-qt6 nor sddm-greeter was found in PATH." >&2
    exit 1
fi
