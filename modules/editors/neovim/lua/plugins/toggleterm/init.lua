local function set_nvimtree_when_open_term(terminal)
	local nvimtree_api = require("nvim-tree.api")
	local nvimtree_view = require("nvim-tree.view")
	if nvimtree_view.is_visible() and terminal.direction == "horizontal" then
		local nvimtree_width = vim.fn.winwidth(nvimtree_view.get_winnr())
		nvimtree_api.tree.toggle()
		nvimtree_view.View.width = nvimtree_width
		nvimtree_api.tree.toggle({ focus = false })
	end
end

require("toggleterm").setup({
	shade_terminals = false,
	open_mapping = [[<c-\>]],
	on_open = function(terminal)
		vim.bo.scrollback = 100000
		set_nvimtree_when_open_term(terminal)
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = 0, silent = true })
		--vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-w>", function()
			vim.fn.feedkeys("\x0c", "n")
			vim.opt_local.scrollback = 1
			vim.api.nvim_command("startinsert")
			vim.api.nvim_feedkeys("clear", "t", false)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "t", true)
			vim.opt_local.scrollback = 100000
		end, { buffer = 0, silent = true })
	end,
	on_close = function(_) end,
	highlights = {},
})
