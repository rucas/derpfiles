local utils = require("utils")

local present, nnn = pcall(require, "nnn")
if not present then
	return
end

nnn.setup({
	command = "nnn -d -o -C",
	set_default_mappings = false,
	replace_netrw = 1,
	layout = {
		window = {
			width = 0.9,
			height = 0.6,
			highlight = "Debug",
		},
	},
	action = {
		["<C-t>"] = "tab split", -- open file in tab
		["<C-x>"] = "split", -- open file in split
		["<C-v>"] = "vsplit", -- open file in vert split
	},
})
