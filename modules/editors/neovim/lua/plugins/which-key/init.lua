local which_key = require("which-key")

which_key.register({
	["<leader>b"] = {
		name = "buffers",
		d = { "Soft Delete (keep window arrangment)" },
		D = { "Hard Delete" },
	},
	["<leader>f"] = {
		name = "file",
		b = { "File Buffers" },
		f = { "Find File" },
		g = { "Git Files" },
		o = { "Recent Files" },
		t = { "File Tree" },
	},
	["<leader>l"] = {
		name = "lsp",
		D = { "Declaration" },
		c = { "Code Action" },
		d = { "Definition" },
		i = { "Implementations" },
		r = { "References" },
		n = { "Rename" },
		t = { "Type Definitions" },
		s = { "Symbols" },
		w = { "Workspace Symbols" },
		x = { "Dynamic Workspace Symbols" },
	},
	["<leader>n"] = {
		name = "neogen",
		c = "Generate Comment for Class",
		f = "Generate Comment for Function",
		F = "Generate Comment for File",
		t = "Generate Comment for Type",
	},
	["<leader>p"] = {
		name = "project",
		s = { "Search Project Sessions" },
		w = { "Save Project Session" },
	},
	["<leader>r"] = {
		name = "repl",
		t = { "Toggle repl" },
		r = { "Restart repl" },
		f = { "Focus repl" },
		h = { "Hide repl" },
	},
	["<leader>/"] = { name = "search" },
	["<leader>t"] = {
		name = "terminal",
		g = { "Gitui" },
		p = { "Procs" },
	},
	["<leader>F"] = { "Format" },
	["<leader>W"] = {
		function()
			vim.cmd("update!")
		end,
		"Save",
	},
	["<leader>Z"] = { "<cmd>ZenMode<cr>", "Zen Mode" },
})

which_key.setup({
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "→", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	window = {
		border = "none",
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 1, 15, 1, 15 },
	},
	layout = {
		align = "left",
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 30, -- spacing between columns
	},
	disable = {
		buftypes = {},
		filetypes = {
			"TelescopePrompt",
		},
	},
	show_help = false,
	show_keys = false,
})
