vim.opt.list = true
-- vim.opt.listchars:append("space:⋅")
-- vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab:› ")
vim.opt.listchars:append("trail:•")

require("ibl").setup({
	exclude = {
		filetypes = {
			-- NOTE: "" for lsp hover with no ft? idk man
			"",
			"NvimTree",
			"OverseerForm",
			"TelescopePrompt",
			"TelescopeResults",
			"help",
			"lsp-installer",
			"lspinfo",
			"markdown",
			"packer",
			"terminal",
			"norg",
		},
		buftypes = {
			"terminal",
		},
	},
	scope = {
		-- space_char_blankline = " ",
		-- show_trailing_blankline_indent = false,
		show_start = false,
		show_exact_scope = true,
	},
})
