require("neogen").setup({
	enabled = true,
	snippet_engine = "luasnip",
	languages = {
		lua = {
			template = {
				annotation_convention = "emmylua",
			},
		},
		python = {
			template = {
				annotation_convention = "reST",
			},
		},
		javascript = {
			template = {
				annotation_convention = "jsdoc",
			},
		},
		javascriptreact = {
			template = {
				annotation_convention = "jsdoc",
			},
		},
	},
})
