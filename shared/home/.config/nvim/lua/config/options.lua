-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here

local opt = vim.opt

-- Line numbers
opt.relativenumber = true

-- Indentation (2 spaces for web dev)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- System clipboard
opt.clipboard = "unnamedplus"

-- Scroll context
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Spell check (LazyVim enables spell for markdown, text, gitcommit)
opt.spelllang = { "en", "es" }

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Picker (use snacks.picker instead of fzf-lua)
vim.g.lazyvim_picker = "snacks"

-- Persistent undo (survives Neovim restart)
opt.undofile = true

-- Line length guide
opt.colorcolumn = "100"
