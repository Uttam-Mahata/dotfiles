# ⚡ High-Performance Vim & Neovim Dotfiles

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Vim: 8.2+](https://img.shields.io/badge/Vim-8.2%2B-green.svg?logo=vim)](https://www.vim.org/)
[![Neovim: 0.10+](https://img.shields.io/badge/Neovim-0.10%2B-57A143.svg?logo=neovim)](https://neovim.io/)
[![Theme: TokyoNight](https://img.shields.io/badge/Theme-TokyoNight%20Storm-7aa2f7.svg)](https://github.com/folke/tokyonight.nvim)

A meticulously tuned developer configuration providing **100% aesthetic and keybinding symmetry** between classic **Vim** and modern **Neovim (LazyVim)**. Built for systems programming (Rust, Go, C++, Python, TypeScript).

---

## 🌟 Highlights

| Feature | Classic Vim (`~/.vimrc`) | Neovim (`~/.config/nvim`) |
|---|---|---|
| **Theme** | TokyoNight (storm) | TokyoNight (storm) |
| **Completion / LSP** | [coc.nvim](https://github.com/neoclide/coc.nvim) (VS Code-grade engine) | [Mason](https://github.com/williamboman/mason.nvim) + Native LSP |
| **Fuzzy Finder** | [FZF.vim](https://github.com/junegunn/fzf.vim) (`:Files`, `:Rg`, `:Buffers`) | [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) |
| **Git Integration** | [vim-fugitive](https://github.com/tpope/vim-fugitive) + [vim-gitgutter](https://github.com/airblade/vim-gitgutter) | [Neogit](https://github.com/NeogitOrg/neogit) + [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) |
| **Key Hints** | [vim-which-key](https://github.com/liuchengxu/vim-which-key) | [which-key.nvim](https://github.com/folke/which-key.nvim) |
| **Statusline** | [vim-airline](https://github.com/vim-airline/vim-airline) | [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) |
| **Multiplexer** | [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) (`<C-h/j/k/l>`) | `vim-tmux-navigator` |
| **Formatting** | 4-space indentation, smartindent, persistent undo | 4-space indentation, smartindent, persistent undo |
| **Clipboard** | System clipboard integration (`unnamedplus`) | System clipboard integration (`unnamedplus`) |

---

## 🚀 Quick Install (1-Line Setup)

Run the automated installer directly in your terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Uttam-Mahata/dotfiles/main/install.sh)
```

The script will:
1. Automatically back up any existing `~/.vimrc` and `~/.config/nvim`.
2. Install `vim-plug` and configure `~/.vimrc` and `~/.vim/coc-settings.json`.
3. Headlessly download and compile all Vim plugins.
4. Set up the modular LazyVim configuration in `~/.config/nvim`.

---

## 🛠 Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/Uttam-Mahata/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Choose your setup:
./install.sh --all     # Set up both Vim and Neovim
./install.sh --vim     # Set up classic Vim only
./install.sh --nvim    # Set up Neovim (LazyVim) only
```

---

## ⌨️ Essential Keybindings Cheat Sheet

Leader key is set to `<Space>` (`let mapleader = " "`):

### File & Buffer Management
| Keybinding | Action |
|---|---|
| `<leader>w` | Save current file (`:w`) |
| `<leader>q` | Quit current window (`:q`) |
| `<leader>x` | Save and quit (`:x`) |
| `<leader>Q` | Force quit all (`:qa!`) |
| `<leader>/` | Clear search highlighting (`:nohlsearch`) |

### Splits & Window Navigation
| Keybinding | Action |
|---|---|
| `<leader>sv` | Vertical split (`:vsplit`) |
| `<leader>sh` | Horizontal split (`:split`) |
| `<leader>sc` | Close current split |
| `<leader>=` | Equalize split dimensions (`<C-w>=`) |
| `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` | Navigate splits and Tmux panes seamlessly |

### Navigation & Search (FZF / Telescope)
| Keybinding | Action |
|---|---|
| `<C-p>` or `<leader>ff` | Fuzzy find files in project |
| `<leader>fg` | Live grep project text (ripgrep) |
| `<leader>fb` | Switch active buffers |
| `<leader>fh` | Search command history |

### Code & LSP Navigation (CoC / Mason)
| Keybinding | Action |
|---|---|
| `gd` | Go to Definition |
| `gy` | Go to Type Definition |
| `gi` | Go to Implementation |
| `gr` | Find References |
| `K` | Hover Documentation / Type Info |
| `<leader>rn` | Rename symbol across project |
| `[g` / `]g` | Jump to previous / next diagnostic error |
| `<Tab>` / `<S-Tab>` | Navigate completion dropdown |
| `<CR>` | Confirm completion selection |

### Git Commands
| Keybinding | Action |
|---|---|
| `<leader>gs` | Git status (`:Git` or Neogit) |
| `<leader>gd` | Git diff split (`:Gdiffsplit`) |
| `<leader>gb` | Git blame (`:Git blame`) |

---

## 📦 Recommended Dependencies

To get the full experience (LSP, icons, and ripgrep):

```bash
# Ubuntu / Debian
sudo apt install ripgrep fzf nodejs npm

# macOS (Homebrew)
brew install ripgrep fzf node

# Arch Linux
sudo pacman -S ripgrep fzf nodejs npm
```

> **Font Recommendation**: Install a [Nerd Font](https://www.nerdfonts.com/) (e.g. *JetBrains Mono Nerd Font* or *FiraCode Nerd Font*) for icons and glyphs.

---

## 📄 License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.
