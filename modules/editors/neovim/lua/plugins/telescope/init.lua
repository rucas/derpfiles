local telescope = require("telescope")
local telescope_actions = require("telescope.actions")
local telescope_utils = require("telescope.utils")

telescope.setup({
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
		prompt_prefix = "",
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
			width = 0.80,
			height = 0.60,
			preview_cutoff = 80,
		},
		path_display = { "absolute" },
		winblend = 0,
		border = true,
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" },
		mappings = {
			n = { ["q"] = telescope_actions.close },
		},
	},
	pickers = {
		buffers = {
			show_all_buffers = true,
			path_display = function(opts, path)
				local tail = telescope_utils.path_smart(path)
				return string.format("%s", tail:gsub("%../", ""))
			end,
			sort_mru = true,
			mappings = {
				i = {
					["<C-d>"] = telescope_actions.delete_buffer,
				},
			},
		},
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
		oldfiles = {
			only_cwd = true,
			path_display = function(opts, path)
				local tail = telescope_utils.path_smart(path)
				return string.format("%s", tail:gsub("%../", ""))
			end,
		},
	},
	file_ignore_patterns = { "node_modules", ".pytest_cache" },
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
		},
		file_browser = {
			-- theme = "ivy",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("file_browser")
