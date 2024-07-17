local which_key = require("which-key")

which_key.add({
	-- Buffers
	{ "<leader>b", group = "buffer" },
	{ "<leader>bd", desc = "Soft Delete (keep window arrangment)" },
	{ "<leader>bD", desc = "Hard Delete" },
	-- Files
	{ "<leader>f", group = "file" },
	{ "<leader>fb", desc = "File Buffers" },
	{ "<leader>ff", desc = "Find Files" },
	{ "<leader>fg", desc = "Git Files" },
	{ "<leader>fo", desc = "Recent Files" },
	{ "<leader>ft", desc = "File Tree" },
	-- Lsp
	{ "<leader>l", group = "lsp" },
	{ "<leader>lD", desc = "Declaration" },
	{ "<leader>lc", desc = "Code Action" },
	{ "<leader>ld", desc = "Definition" },
	{ "<leader>li", desc = "Implementations" },
	{ "<leader>lr", desc = "References" },
	{ "<leader>ln", desc = "Rename" },
	{ "<leader>lt", desc = "Type Definitions" },
	{ "<leader>ls", desc = "Symbols" },
	{ "<leader>lw", desc = "Workspace Symbols" },
	{ "<leader>lx", desc = "Dynamic Workspace Symbols" },
	-- Search
	{ "<leader>/", desc = "search" },
	-- Terminal
	{ "<leader>t", group = "terminal" },
	{ "<leader>tg", desc = "Gitui" },
	{ "<leader>tp", desc = "Procs" },
	{
		"<leader>F",
		function()
			vim.cmd("Format")
		end,
		desc = "Format",
	},
	{
		"<leader>W",
		function()
			vim.cmd("update!")
		end,
		desc = "Save",
	},
	{ "<leader>Z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
})

which_key.setup({
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "→", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	--win = {
	--	border = "none",
	--	margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
	--	-- padding = { 1, 15, 1, 15 },
	--},
	layout = {
		align = "left",
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 60 }, -- min and max width of the columns
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
