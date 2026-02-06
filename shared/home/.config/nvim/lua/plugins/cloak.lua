return {
  {
    "laytan/cloak.nvim",
    event = "BufRead",
    opts = {
      patterns = {
        { file_pattern = ".env*", cloak_pattern = "=.+", replace = "= ..." },
      },
    },
  },
}
