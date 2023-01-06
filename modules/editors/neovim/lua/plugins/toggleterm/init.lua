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
	on_open = set_nvimtree_when_open_term,
	highlights = {
		Normal = {
			guibg = "#2b2b2b",
		},
		SignColumn = {
			guibg = "#2b2b2b",
		},
	},
})
