local telescope = require("telescope")

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
		prompt_prefix = " ",
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
		path_display = { "truncate" },
		winblend = 0,
		border = true,
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

telescope.load_extension("fzf")
telescope.load_extension("file_browser")
