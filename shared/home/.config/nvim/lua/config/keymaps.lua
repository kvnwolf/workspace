-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here

local map = vim.keymap.set

-- Exit insert mode with jj
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Redo with U (undo is u by default)
map("n", "U", "<C-r>", { desc = "Redo" })

-- Center screen after navigation
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
map("n", "*", "*zzzv", { desc = "Search word under cursor (centered)" })
map("n", "G", "Gzz", { desc = "Go to bottom (centered)" })
map("n", "{", "{zz", { desc = "Prev paragraph (centered)" })
map("n", "}", "}zz", { desc = "Next paragraph (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Start/end of line (ergonomic)
map({ "n", "v" }, "H", "^", { desc = "Start of line" })
map({ "n", "v" }, "L", "$", { desc = "End of line" })

-- Paste in visual mode without overwriting register
map("v", "p", '"_dP', { desc = "Paste without register overwrite" })

-- Better visual indent (reselect after indent)
map("v", "<", "<gv", { desc = "Indent left (reselect)" })
map("v", ">", ">gv", { desc = "Indent right (reselect)" })

-- Quick save
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Center on jump/definition navigation (completing Dillon's pattern)
map("n", "gd", "gdzz", { desc = "Go to definition (centered)" })
map("n", "<C-i>", "<C-i>zz", { desc = "Jump forward (centered)" })
map("n", "<C-o>", "<C-o>zz", { desc = "Jump backward (centered)" })
map("n", "%", "%zz", { desc = "Matching bracket (centered)" })
map("n", "#", "#zzzv", { desc = "Search word backward (centered)" })

-- Last buffer toggle (Dillon's pattern)
map("n", "<leader>'", "<cmd>b#<cr>", { desc = "Switch to last buffer" })
