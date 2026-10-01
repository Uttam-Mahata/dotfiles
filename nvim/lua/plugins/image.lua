-- Image and PDF viewer inline in the editor, using the Kitty Graphics Protocol.
-- Requires: kitty terminal (have it), ImageMagick (`magick`, have it),
-- Ghostscript (`gs`, have it) for PDF page rasterization.
-- Open any .png/.jpg/.pdf/etc directly with :e file.pdf, or view images
-- referenced inline in markdown/html/latex buffers automatically.

return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
      },
    },
  },
}
