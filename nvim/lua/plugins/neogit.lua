-- Neogit: magit-style git UI.
-- <leader>gn opens the status buffer. Inside it: s stage, u unstage,
-- c c commit, P push, F pull, ? help.

return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim", -- side-by-side diffs
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Neogit", "NeogitCommit", "NeogitLogCurrent" },
    keys = {
      { "<leader>gn", function() require("neogit").open() end, desc = "Neogit" },
      { "<leader>gN", function() require("neogit").open({ kind = "split" }) end, desc = "Neogit (split)" },
      { "<leader>gc", function() require("neogit").open({ "commit" }) end, desc = "Neogit commit" },
      { "<leader>gp", function() require("neogit").open({ "pull" }) end, desc = "Neogit pull" },
      { "<leader>gP", function() require("neogit").open({ "push" }) end, desc = "Neogit push" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
    },
    opts = {
      graph_style = "unicode",
      kind = "tab",
      -- glyphs as \u{...} escapes so the file stays pure ASCII
      signs = {
        hunk = { "", "" },
        item = { "\u{f0da}", "\u{f0d7}" },
        section = { "\u{f0da}", "\u{f0d7}" },
      },
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
  },
}
