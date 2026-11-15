return {
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    ft = { "markdown" },
    opts = {
      glow_path = "/usr/bin/glow",
      border = "rounded",
      style = "dark",
      pager = true,
      width_ratio = 0.85,
      height_ratio = 0.85,
    },
    keys = {
      { "<leader>mg", "<cmd>Glow<cr>", desc = "Glow Preview", ft = "markdown" },
      { "<leader>mp", "<cmd>Glow<cr>", desc = "Markdown Preview (Glow)", ft = "markdown" },
    },
  },
}
