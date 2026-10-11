# ❄️ Arch Linux • Hyprland • Waybar • SDDM • Neovim Dotfiles

[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793d1?logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-0.56%2B%20(Lua)-00c0ff?logo=wayland&logoColor=white)](https://hyprland.org/)
[![Waybar](https://img.shields.io/badge/Waybar-0.10%2B-ffffff?logo=wayland&logoColor=black)](https://github.com/Alexays/Waybar)
[![SDDM](https://img.shields.io/badge/SDDM-Qt6%20Arch%20Slate-1793d1)](https://github.com/sddm/sddm)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B%20(LazyVim)-57A143.svg?logo=neovim)](https://neovim.io/)
[![Kitty](https://img.shields.io/badge/Kitty-GPU%20Terminal-20262c?logo=kitty)](https://sw.kovidgoyal.net/kitty/)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)

A complete, production-grade personal dotfiles ecosystem configured from scratch around the **Arch Linux aesthetic palette** (`#1793d1` / `#222222`) and **TokyoNight Storm**. Engineered for seamless multi-monitor development, frosted glass blur consistency, and ultra-fast keyboard-driven productivity.

---

## 🎨 Unified Blur & Aesthetic Architecture

Every desktop component is calibrated for visual coherence and legibility:

| Component | Visual Styling & Blur Implementation |
|---|---|
| **Hyprland** | Native Lua (`hyprland.lua`), rounded corners (10px), subtle borders (`#1793d1`), dynamic dwindle layout, and compositor blur. |
| **Waybar** | Top bar with flat high-contrast typography (Adwaita & Noto Sans), Arch blue `#1793d1` active indicators, and blurred wallpaper backdrop (`waybar-blur` layer rule). |
| **Hyprlock** | Frosted glass lockscreen with 3 blur passes, 7 blur size, live clock & date, `$USER@archlinux` banner, and Arch gradient input box. |
| **SDDM Login** | Custom **Arch Slate** QtQuick 6 greeter with matching Fuji night backdrop, live clock/date, Arch logo, and smooth authentication feedback. |
| **Kitty Terminal** | GPU-accelerated terminal with `background_opacity 0.35` and `background_blur 32`, TokyoNight palette, and split navigation. |
| **Wofi** | Translucent rounded Spotlight launcher (`#outer-box` `rgba(26,27,38,0.62)`) with subtle Arch blue border and compositor layer blur (`popin 92%`). |
| **Neovim** | LazyVim with transparent TokyoNight background integration (`<leader>uT` live toggle) and blended popups (`winblend = 10`, `pumblend = 10`). |

---

## 📂 Repository Structure

```
~/projects/dotfiles/
├── install.sh                  # Comprehensive modular installer (symlinks & backups)
├── hypr/
│   ├── hyprland.lua            # Hyprland native Lua config (monitors, keybinds, rules)
│   ├── hyprlock.conf           # Arch Linux themed frosted lockscreen
│   ├── hypridle.conf           # Idle daemon (dim -> lock -> dpms off -> suspend)
│   ├── hyprpaper.conf          # Wallpaper daemon configuration
│   └── scripts/
│       └── monitor-sync.sh     # Hotplug monitor & workspace rebalancing
├── waybar/
│   ├── config.jsonc            # Bar layout, modules, and persistent workspaces
│   ├── style.css               # Clean typography and Arch blue accents
│   └── scripts/
│       ├── power-menu.sh       # Interactive Wofi power & logout confirmation menu
│       ├── tailscale-exit.sh   # Tailscale exit node picker & toggle
│       └── wg.sh               # WireGuard VPN quick toggle & status
├── wofi/
│   ├── config                  # Spotlight search configuration
│   └── style.css               # Frosted translucent theme
├── kitty/
│   └── kitty.conf              # 35% opacity + blur, font ligatures, splits & tabs
├── sddm/
│   └── themes/arch-slate/      # Custom QtQuick SDDM theme
│       ├── Main.qml
│       ├── theme.conf
│       ├── metadata.desktop
│       ├── archlinux-logo.png
│       └── background.jpg
├── scripts/
│   ├── display-mode            # Switch between extend / mirror / external / laptop
│   ├── new-workspace           # Smart empty workspace creator on focused screen
│   ├── install-sddm.sh         # System installer for SDDM theme (sudo)
│   └── test-sddm.sh            # In-window SDDM theme tester
├── wallpapers/
│   ├── fuji-night-1080p.jpg    # Primary desktop & lockscreen wallpaper
│   └── ...                     # Programming & cheatsheet wallpapers
├── nvim/                       # Production LazyVim setup with transparent toggle
└── vim/                        # Classic Vimrc + coc.nvim
```

---

## 🚀 Installation & Quickstart

Clone this repository and run the automated installer:

```bash
git clone https://github.com/Uttam-Mahata/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
chmod +x install.sh
```

### Full Setup (Desktop + Neovim + Vim)
```bash
./install.sh --all
```

> **Note:** By default, `install.sh` uses **symlinks** (`--link`) so that any adjustments made inside `~/projects/dotfiles` take effect immediately. Existing configuration files are automatically backed up with timestamps (`*.bak.YYYYMMDD_HHMMSS`).

### Modular Installation
```bash
./install.sh --desktop      # All desktop tools (Hyprland, Waybar, Kitty, Wofi, Scripts, Wallpapers)
./install.sh --hypr         # Hyprland, Hyprlock, Hypridle, Hyprpaper
./install.sh --waybar       # Waybar configuration & helper scripts
./install.sh --kitty        # Kitty terminal configuration
./install.sh --wofi         # Wofi application launcher
./install.sh --scripts      # Helper utilities (display-mode, new-workspace) to ~/.local/bin
./install.sh --wallpapers   # Wallpapers to ~/Pictures/Wallpapers
./install.sh --nvim         # Neovim (LazyVim) suite
./install.sh --vim          # Classic Vim suite
```

### SDDM Theme Setup
Preview the Arch Slate login screen in a test window:
```bash
./scripts/test-sddm.sh
```

Apply the theme system-wide (requires sudo):
```bash
./scripts/install-sddm.sh
```

---

## ⌨️ Desktop Shortcuts Reference

### System & Launchers
| Shortcut | Action |
|---|---|
| `SUPER + Q` | Launch Kitty terminal |
| `SUPER + R` | Application launcher (Wofi drun) |
| `SUPER + E` | Open Dolphin file manager |
| `SUPER + Escape` | Lock session immediately (`hyprlock`) |
| `SUPER + M` | Exit / Power menu |
| `SUPER + SHIFT + V` | Clipboard history search (`cliphist` + Wofi) |
| `SUPER + SHIFT + C` | Color picker (`hyprpicker --autocopy`) |
| `SUPER + SHIFT + W` | **Next Wallpaper** (Rotate wallpaper immediately) |

### Window & Layout Management
| Shortcut | Action |
|---|---|
| `SUPER + C` | Close focused window |
| `SUPER + V` | Toggle floating state |
| `SUPER + P` | Toggle pseudo-tile |
| `SUPER + J` | Toggle dwindle split orientation |
| `SUPER + Left/Right/Up/Down` | Move focus in direction |
| `SUPER + LMB (drag)` | Move window |
| `SUPER + RMB (drag)` | Resize window |

### Multi-Monitor & Displays
| Shortcut | Action |
|---|---|
| `SUPER + SHIFT + P` | **Display mode picker** (Extend / Mirror / External Only / Laptop Only) |
| `SUPER + ,` / `SUPER + .` | Focus previous / next monitor |
| `SUPER + SHIFT + ,` / `.` | Move active window to other monitor |
| `SUPER + ALT + ,` / `.` | Move active workspace to other monitor |
| `SUPER + N` | Open **new empty workspace** on focused monitor |
| `SUPER + 1..5` | Workspaces 1–5 (Laptop panel `eDP-1`) |
| `SUPER + 6..0` | Workspaces 6–10 (External monitor `HDMI-A-1`) |
| `SUPER + S` | Toggle special scratchpad workspace |

### Screenshots (grim + slurp)
| Shortcut | Action |
|---|---|
| `Print` | Interactive area selection -> Save to `~/Pictures/Screenshots` & copy |
| `SUPER + Print` | Full screen capture -> Save & copy |
| `SHIFT + Print` | Active window capture -> Save & copy |
| `CTRL + Print` | Interactive area selection -> Copy to clipboard only |

---

## 💻 Neovim Highlights & Blur Controls

- **Transparency Toggle**: Press `<leader>uT` in Normal mode to toggle TokyoNight background transparency on the fly.
- **Buffer Management**: `<leader>c` or `<leader>bd` to delete buffer, `]b` / `[b` for next / previous tab.
- **Fuzzy Finding**: `<leader>ff` for files, `<leader>fg` for live ripgrep, `<leader>fb` for buffers.
- **Git**: `<leader>gs` for Neogit, `<leader>gd` for diff view.

---

## 📄 License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.
