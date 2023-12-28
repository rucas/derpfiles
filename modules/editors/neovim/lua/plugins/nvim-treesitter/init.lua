local treesitter = require("nvim-treesitter.configs")

treesitter.setup({
	indent = {
		enable = false,
	},
	highlight = {
		enable = true,
		use_languagetree = true,
	},
})
