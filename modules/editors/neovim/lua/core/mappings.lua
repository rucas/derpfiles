-- Leader key
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

-- Use semicolon to enter command mode also
vim.keymap.set("n", ";", ":")

-- Exit hard and fast!
vim.keymap.set("n", "ZZ", ":w | qa<CR>", { silent = true })

-- buffer delete preserve spacing
--vim.keymap.set("n", "<leader>bd", ":bp | bd # <CR>", { silent = true })

-- NOTE: os specific might be "*y
-- send to os specific copy-paste
vim.keymap.set("v", "YY", '"+y')
