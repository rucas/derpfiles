local neogen = require("neogen")

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

vim.keymap.set({ "n" }, "<Leader>nc", function()
	neogen.generate({ type = "class" })
end, { noremap = true, silent = true })

vim.keymap.set({ "n" }, "<Leader>nf", function()
	neogen.generate({ type = "func" })
end, { noremap = true, silent = true })

vim.keymap.set({ "n" }, "<Leader>nF", function()
	neogen.generate({ type = "file" })
end, { noremap = true, silent = true })

vim.keymap.set({ "n" }, "<Leader>nt", function()
	neogen.generate({ type = "type" })
end, { noremap = true, silent = true })
