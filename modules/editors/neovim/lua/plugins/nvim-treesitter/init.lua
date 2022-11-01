local ok_treesitter, treesitter = pcall(require, "nvim-treesitter.configs")
local ok_gruvbox, gruvbox = pcall(require, "gruvbox")
if not (ok_treesitter or ok_gruvbox) then
	error("Error loading " .. "\n\n" .. treesitter .. gruvbox)
	return
end

treesitter.setup({
	ensure_installed = {},
	indent = {
		enable = true,
	},
	highlight = {
		enable = true,
		use_languagetree = true,
	},
	rainbow = {
		enable = true,
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		colors = {
			"#fb4934",
			"#b8bb26",
			"#fabd2f",
			"#83a598",
			"#d3869b",
			"#8ec07c",
			"#fe8019",
			"#cc241d",
			"#98971a",
			"#d79921",
			"#458588",
			"#b16286",
			"#689d6a",
			"#d65d0e",
			"#9d0006",
			"#79740e",
			"#b57614",
			"#076678",
			"#8f3f71",
			"#427b58",
			"#af3a03"
		},
		playground = {
			enable = true,
			disable = {},
			updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
			persist_queries = false, -- Whether the query persists across vim sessions
			keybindings = {
			  toggle_query_editor = 'o',
			  toggle_hl_groups = 'i',
			  toggle_injected_languages = 't',
			  toggle_anonymous_nodes = 'a',
			  toggle_language_display = 'I',
			  focus_language = 'f',
			  unfocus_language = 'F',
			  update = 'R',
			  goto_node = '<cr>',
			  show_help = '?',
			},
		}
	},
})
