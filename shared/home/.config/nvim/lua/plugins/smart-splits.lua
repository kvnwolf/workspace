return {
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split/pane" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split/pane" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split/pane" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split/pane" },
    },
  },
}
