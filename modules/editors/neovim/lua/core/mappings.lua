-- Leader key
vim.g.mapleader = ","

-- Use semicolon to enter command mode also
vim.keymap.set("n", ";", ":")

-- Exit hard and fast!
vim.keymap.set("n", "ZZ", ":w | qa<CR>", { silent = true })

-- NOTE: os specific might be "*y
-- ctrl-c copy visual mode
vim.keymap.set("v", "YY", '"+y')
