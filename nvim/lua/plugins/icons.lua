-- Nerd Font icons: file-type icons, folder/directory icons, git status glyphs.
-- Requires a patched Nerd Font in the terminal (JetBrainsMono Nerd Font Mono).
--
-- NOTE: glyphs are written as \u{...} escapes rather than literal characters so
-- the file stays pure ASCII and cannot be mangled by editors/tools that strip
-- Private Use Area codepoints.

return {
  -- Used directly by telescope, lualine and bufferline.
  { "nvim-tree/nvim-web-devicons", lazy = false },

  -- mini.icons is LazyVim's icon provider and also mocks nvim-web-devicons.
  -- `directory` is the table that gives folders their glyphs.
  {
    "nvim-mini/mini.icons",
    lazy = false,
    opts = {
      directory = {
        [".git"] = { glyph = "\u{e5fb}", hl = "MiniIconsOrange" },
        [".github"] = { glyph = "\u{e5fd}", hl = "MiniIconsGrey" },
        ["node_modules"] = { glyph = "\u{e5fa}", hl = "MiniIconsGreen" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Neo-tree: folder icons, expander arrows and git status symbols
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "\u{f0da}",
          expander_expanded = "\u{f0d7}",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "\u{f07b}",
          folder_open = "\u{f07c}",
          folder_empty = "\u{f0256}",
          folder_empty_open = "\u{f0dcf}",
          default = "\u{f15b}",
          -- neo-tree's default provider blanks the folder glyph for
          -- directories; re-assert it here so folders always get an icon.
          provider = function(icon, node)
            if node.type == "directory" then
              local ok, mi = pcall(require, "mini.icons")
              local glyph, hl
              if ok then
                glyph, hl = mi.get("directory", node.name)
              end
              if glyph == nil or glyph == "" then
                glyph = node:is_expanded() and "\u{f07c}" or "\u{f07b}"
                hl = "NeoTreeDirectoryIcon"
              end
              icon.text = glyph
              icon.highlight = hl or "NeoTreeDirectoryIcon"
            elseif node.type == "file" then
              local ok, mi = pcall(require, "mini.icons")
              if ok then
                local glyph, hl = mi.get("file", node.name)
                if glyph and glyph ~= "" then
                  icon.text = glyph
                  icon.highlight = hl or icon.highlight
                end
              end
            end
          end,
        },
        git_status = {
          symbols = {
            added = "\u{f067}",
            modified = "\u{f111}",
            deleted = "\u{f014}",
            renamed = "\u{f0055}",
            untracked = "\u{f128}",
            ignored = "\u{f02b}",
            unstaged = "\u{f0131}",
            staged = "\u{f00c}",
            conflict = "\u{f071}",
          },
        },
      },
    },
  },
}
