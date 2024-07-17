require("better_escape").setup({
	timeout = vim.o.timeoutlen,
	default_mappings = false,
	mappings = {
		i = {
			j = {
				k = "<Esc>",
			},
		},
		c = {
			j = {
				k = "<Esc>",
			},
		},
		v = {
			j = {
				k = "<Esc>",
			},
		},
		s = {
			j = {
				k = "<Esc>",
			},
		},
	},
})
