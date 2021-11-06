local utils = require("utils")

local present, tele = pcall(require, "telescope")
if not present then
	return
end

tele.setup({
	pickers = {
		find_files = {
			find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", "{.git,.idea}" },
		},
		git_files = {
			find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", "{.git,.idea}" },
		},
		live_grep = {
			find_command = { "rg", "--smart_case", "--no-heading" },
		},
		lsp_definitions = {
			timeout = 1000,
		},
	},
	file_ignore_patterns = { "node_modules" },
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = false, -- override the generic sorter
			override_file_sorter = false, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
		},
	},
})

tele.load_extension("fzf")

utils.map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
utils.map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>")
utils.map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
utils.map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
utils.map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")

utils.map("n", "<leader>ft", "<cmd>Telescope treesitter<cr>")
utils.map("n", "<leader>fr", "<cmd>Telescope lsp_references<cr>")
