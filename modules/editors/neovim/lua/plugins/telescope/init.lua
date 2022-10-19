local present, tele = pcall(require, "telescope")
if not present then
	return
end

tele.setup({
	defaults = {
		preview = {
			-- if file is too big...just the tip
			filesize_hook = function(filepath, bufnr, opts)
				local max_bytes = 10000
				local cmd = { "head", "-c", max_bytes, filepath }
				require("telescope.previewers.utils").job_maker(cmd, bufnr, opts)
			end,
		},
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--trim",
		},
		prompt_prefix = "   ",
		selection_caret = "  ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
				results_width = 0.8,
			},
			vertical = {
				mirror = false,
			},
			width = 0.87,
			height = 0.80,
			preview_cutoff = 120,
		},
		path_display = { "truncate" },
		winblend = 0,
		border = false,
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" },
		mappings = {
			n = { ["q"] = require("telescope.actions").close },
		},
	},
	pickers = {
		find_files = {
			find_command = {
				"fd",
				"--type",
				"f",
				"--hidden",
				"--follow",
				"--exclude",
				"{.git,.idea}",
				"--strip-cwd-prefix",
			},
		},
		commands = {
			preview = false,
		},
		git_files = {
			find_command = {
				"fd",
				"--type",
				"f",
				"--hidden",
				"--follow",
				"--exclude",
				"{.git,.idea}",
				"--strip-cwd-prefix",
			},
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
		file_browser = {
			-- theme = "ivy",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
		},
	},
})

tele.load_extension("fzf")
tele.load_extension("file_browser")

local finders = {}

-- Dropdown list theme using a builtin theme definitions :
-- print(vim.inspect(entry))
local center_list = require("telescope.themes").get_dropdown({
	entry_maker = function(entry)
		return {
			value = entry,
			display = entry.name,
			ordinal = entry.name,
		}
	end,
	border = false,
})

finders.command_finder = function()
	local opts = vim.deepcopy(center_list)
	opts.cwd = vim.fn.stdpath("config")
	require("telescope.builtin").commands(opts)
end

finders.command_history_finder = function()
	local opts = vim.deepcopy(center_list)
	opts.cwd = vim.fn.stdpath("config")
	require("telescope.builtin").command_history(opts)
end

return finders
