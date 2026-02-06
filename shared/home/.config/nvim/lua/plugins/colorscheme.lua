return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true, -- matches Ghostty 90% opacity + blur
      custom_highlights = function(colors)
        return {
          SnacksDashboardHeader = { fg = colors.yellow },
        }
      end,
    },
  },

  -- Set catppuccin as the LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
