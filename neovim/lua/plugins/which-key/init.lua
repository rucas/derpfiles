local present, which_key = pcall(require, "which-key")
if not present then
	return
end

which_key.register({
	["<leader>c"] = {
		name = "+commands",
		s = { "<cmd>lua require'plugins.telescope'.command_finder()<cr>", "Commands" },
		h = { "<cmd>lua require'plugins.telescope'.command_history_finder()<cr>", "Command History" },
    },
	["<leader>e"] = {
		name = "+emojis",
		s = { "<cmd>Telescope symbols<cr>", "Emojis" },
    },
	["<leader>f"] = {
		name = "+file",
		f = { "<cmd>Telescope find_files<cr>", "Find File" },
		o = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
		b = { "<cmd>Telescope buffers<cr>", "Search Files in Buffers" },
	},
	["<leader>l"] = {
		name = "+lsp",
		r = { "<cmd>Telescope lsp_references<cr>", "LSP References" },
		i = { "<cmd>Telescope lsp_implementations<cr>", "LSP Implementations" },
		d = { "<cmd>Telescope lsp_document_symbols<cr>", "LSP Document Symbols" },
		t = { "<cmd>Telescope lsp_type_definitions<cr>", "LSP Type Definitions" },
		w = { "<cmd>Telescope lsp_workspace_symbols<cr>", "LSP Workspace Symbols" },
		x = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "LSP Dynamic Workspace Symbols" },
	},
	["<leader>g"] = {
		name = "+git",
		c = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
		b = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
		s = { "<cmd>Telescope git_status<cr>", "Git Status" },
	},
	["<leader>s"] = {
		name = "+search",
		s = { "<cmd>Telescope grep_string<cr>", "Grep Under Cursor" },
		g = { "<cmd>Telescope live_grep<cr>", "Grep Search" },
		h = { "<cmd>Telescope help_tags<cr>", "Search Help Tags" },
	},
	["<leader>t"] = {
        name = "+treesitter",
		s = { "<cmd>Telescope treesitter<cr>", "Treesitter" },
    },
})

which_key.setup({})
