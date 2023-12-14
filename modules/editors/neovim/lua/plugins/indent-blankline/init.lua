vim.opt.list = true
-- vim.opt.listchars:append("space:⋅")
-- vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab:› ")
vim.opt.listchars:append("trail:•")

local hooks = require("ibl.hooks")
hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)

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
		show_start = false,
		show_end = false,
		show_exact_scope = true,
	},
})
