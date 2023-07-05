local treesitter = require("nvim-treesitter.configs")

treesitter.setup({
	indent = {
		enable = true,
	},
	highlight = {
		enable = true,
		use_languagetree = true,
		-- additional_vim_regex_highlighting = { "python", }
	},
})
