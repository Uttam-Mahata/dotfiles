-- Ported from the previous hand-rolled config.

return {
  -- Colorscheme: tokyonight-storm, transparent so the terminal's own opacity (kitty 85%)
  -- and the desktop blur show through. Toggle with <leader>uT (see keymaps.lua).
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "storm",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      on_highlights = function(hl, _)
        if vim.g.nvim_transparent == false then
          return
        end
        -- groups some plugins still paint with a solid background
        local clear = {
          "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "NeoTreeWinSeparator",
          "BufferLineFill", "BufferLineBackground",
          "SnacksPickerNormal", "SnacksPickerBorder", "SnacksNormal",
          "WhichKeyNormal", "WhichKeyFloat",
          "Pmenu", "PmenuSbar",
        }
        for _, group in ipairs(clear) do
          hl[group] = vim.tbl_extend("force", hl[group] or {}, { bg = "NONE" })
        end
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-storm" },
  },

  -- Seamless vim <-> tmux pane navigation with <C-h/j/k/l>
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Pane left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Pane down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Pane up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Pane right" },
    },
  },

  -- Extra telescope keys to match the old muscle memory
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    },
  },

  -- <leader>x is remapped to :x (save+quit), so expose Trouble under <leader>D
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>Dd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>DD", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
      { "<leader>Ds", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
      { "<leader>Dl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>Dq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },

  -- vim-fugitive kept for :Git / :Gdiffsplit alongside Neogit
  { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" } },

  -- nvim-surround (LazyVim ships mini.surround; this keeps the old bindings)
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
}
