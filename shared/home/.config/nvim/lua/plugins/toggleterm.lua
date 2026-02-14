return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 12
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-/>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
          border = "curved",
          winblend = 0,
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

      vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal float" })
      vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal horizontal" })
      vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal vertical" })
      vim.keymap.set("n", "<leader>t1", "<cmd>1ToggleTerm<cr>", { desc = "Terminal 1" })
      vim.keymap.set("n", "<leader>t2", "<cmd>2ToggleTerm<cr>", { desc = "Terminal 2" })
      vim.keymap.set("n", "<leader>t3", "<cmd>3ToggleTerm<cr>", { desc = "Terminal 3" })
      vim.keymap.set("n", "<leader>t4", "<cmd>4ToggleTerm<cr>", { desc = "Terminal 4" })
      vim.keymap.set("n", "<leader>t5", "<cmd>5ToggleTerm<cr>", { desc = "Terminal 5" })
      vim.keymap.set("n", "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", { desc = "Toggle all terminals" })
    end,
    keys = {
      { "<C-/>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<C-_>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal (alternative)" },
    },
  },
}
