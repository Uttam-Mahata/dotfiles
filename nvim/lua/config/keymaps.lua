-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ============================================================
-- Ported from the previous hand-rolled config.
-- LazyVim's own keymaps are already loaded at this point, so
-- anything below intentionally wins over the defaults.
--
-- Notable overrides:
--   <leader>w  save          (shadows LazyVim's window group; use <C-w>,
--                             <leader>- and <leader>| for splits)
--   <leader>q  quit          (shadows LazyVim's quit group)
--   <leader>x  save + quit   (Trouble moved to <leader>D — see plugins/editor.lua)
-- ============================================================
local map = vim.keymap.set

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
map("n", "<leader>x", "<cmd>x<cr>", { desc = "Save and quit" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all (force)" })

-- Splits / windows
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalize splits" })

-- Buffers and tabs
map("n", "<leader>c", function() Snacks.bufdelete() end, { desc = "Close file buffer" })
map("n", "<leader>C", function() Snacks.bufdelete({ force = true }) end, { desc = "Force close buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete other buffers" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Only this tab" })

-- Move lines up/down
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep selection after indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<PageDown>", "<C-d>zz")
map("n", "<PageUp>", "<C-u>zz")

-- Clear search highlight with <Esc> or <leader>/
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })
map("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Toggles
map("n", "<leader>n", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative number" })
map("n", "<leader>sp", "<cmd>set spell! spelllang=en_us<cr>", { desc = "Toggle spell" })

-- Yank / paste conveniences
map("n", "Y", "y$")
map("x", "p", '"_dP')
map("n", "<leader>d", '"_d', { desc = "Delete (no yank)" })

-- Trim trailing whitespace
map("n", "<leader>tw", [[<cmd>%s/\s\+$//e<cr>]], { desc = "Trim trailing whitespace" })

-- Edit / reload config
map("n", "<leader>ev", "<cmd>vsplit $MYVIMRC<cr>", { desc = "Edit init.lua" })

-- Terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
