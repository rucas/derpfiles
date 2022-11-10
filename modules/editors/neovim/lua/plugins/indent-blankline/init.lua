vim.opt.list = true
--vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab:› ")
vim.opt.listchars:append("trail:•")

-- no ~ at end of line
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

require("indent_blankline").setup({
	filetype_exclude = {
		"alpha",
		"dashboard",
		"help",
		"terminal",
		"packer",
		"lspinfo",
		"markdown",
		"lsp-installer",
		"TelescopePrompt",
		"TelescopeResults",
	},
	buftype_exclude = { "terminal" },
	space_char_blankline = " ",
	show_current_context = true,
	show_first_indent_level = false,
	show_trailing_blankline_indent = false,
	show_end_of_line = true,
})
