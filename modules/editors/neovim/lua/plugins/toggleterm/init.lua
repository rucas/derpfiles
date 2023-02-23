local function set_nvimtree_when_open_term(terminal)
	local nvimtree = require("nvim-tree")
	local nvimtree_view = require("nvim-tree.view")
	if nvimtree_view.is_visible() and terminal.direction == "horizontal" then
		local nvimtree_width = vim.fn.winwidth(nvimtree_view.get_winnr())
		nvimtree.toggle()
		nvimtree_view.View.width = nvimtree_width
		nvimtree.toggle(false, true)
	end
end

require("toggleterm").setup({
	shade_terminals = false,
	open_mapping = [[<c-\>]],
	on_open = function(terminal)
		vim.bo.scrollback = 100000
		set_nvimtree_when_open_term(terminal)
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = 0, silent = true })
		vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-w>", function()
			vim.fn.feedkeys("\x0c", "n")
		end, { buffer = 0, silent = true })
		--vim.keymap.set("t", "<C-f>", function()
		--	vim.fn.feedkeys("\x0c", "n")
		--	local sb = vim.bo.scrollback
		--	vim.bo.scrollback = 1
		--	vim.bo.scrollback = sb
		--end, { buffer = 0, silent = true })
	end,
	on_close = function(_) end,
	highlights = {},
})
