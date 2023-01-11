-- Leader key
vim.g.mapleader = ","

-- Use semicolon to enter command mode also
vim.keymap.set("n", ";", ":")

-- Exit hard and fast!
vim.keymap.set("n", "ZZ", ":w | qa<CR>", { silent = true })

-- NOTE: trying to get shit not printing to cmd?
vim.keymap.set("n", "pf", function()
	require("telescope.builtin").git_files()
	require("lualine").refresh({
		scope = "all",
		place = { "statusline" },
	})
end, { silent = true })
vim.keymap.set("n", "<leader>w", ":silent w<CR>", { silent = true })
vim.keymap.set("n", "<leader>m", ":silent Telescope man_pages<CR>", { silent = true })
vim.keymap.set("n", "bd", ":bd<CR>", { silent = true })

-- NOTE: os specific might be "*y
-- ctrl-c copy visual mode
vim.keymap.set("v", "YY", '"+y')
