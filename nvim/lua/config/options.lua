-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ============================================================
-- Ported from the previous hand-rolled config
-- ============================================================
local opt = vim.opt

-- Indentation: 4 spaces (LazyVim defaults to 2)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

-- Editing / UI
opt.number = true
opt.relativenumber = false
opt.cursorline = false
opt.scrolloff = 8
opt.mouse = ""
opt.hidden = true
opt.clipboard = "unnamedplus"
opt.showcmd = true
opt.wildmenu = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 300
opt.splitright = true
opt.splitbelow = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Persistent undo (same directory the old config used)
opt.undofile = true
local undodir = vim.fn.expand("~/.local/state/nvim/undodir")
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir

-- LazyVim: use a Nerd Font (enables all the icon sets)
vim.g.have_nerd_font = true
