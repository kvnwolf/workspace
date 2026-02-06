return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = "ordinal",
      },
    },
    keys = (function()
      local keys = {}
      for i = 1, 9 do
        table.insert(keys, { "<C-" .. i .. ">", "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", desc = "Buffer " .. i })
      end
      table.insert(keys, { "<C-0>", "<cmd>BufferLineGoToBuffer -1<cr>", desc = "Last Buffer" })
      return keys
    end)(),
  },
}
