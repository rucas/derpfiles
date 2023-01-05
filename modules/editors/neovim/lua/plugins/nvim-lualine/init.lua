local telescope_extension = {
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = { "encoding", "fileformat" },
		lualine_y = { { "branch", icon = "" } },
		lualine_z = {},
	},
	filetypes = { "TelescopePrompt" },
}

local gruvybox = require("lualine.themes.gruvbox-material")
gruvybox.normal.a.bg = "#2b2b2b"
gruvybox.normal.b.bg = "#2b2b2b"
gruvybox.normal.c.bg = "#2b2b2b"
gruvybox.visual.a.bg = "#2b2b2b"
gruvybox.insert.a.bg = "#2b2b2b"
gruvybox.inactive.a.bg = "#2b2b2b"
gruvybox.command.a.bg = "#2b2b2b"
gruvybox.replace.a.bg = "#2b2b2b"

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = gruvybox,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = { "Dashboard" },
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = true,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = {
			{
				function()
					return string.rep(" ", require("nvim-tree").config.view.width - 1)
				end,
				cond = require("nvim-tree.view").is_visible,
				padding = { left = 1, right = 1 },
				color = { fg = "#d4be98", bg = "#2b2b2b" },
			},
		},
		lualine_b = {},
		lualine_c = {
			{
				"filetype",
				icon_only = true,
				padding = { left = 1, right = 0 },
			},
			{
				"filename",
				file_status = true,
				newfile_status = false,
				symbols = {
					modified = "[+]", -- Text to show when the file is modified.
					readonly = "[]", -- Text to show when the file is non-modifiable or readonly.
					unnamed = "[No Name]", -- Text to show for unnamed buffers.
					newfile = "[New]", -- Text to show for new created file before first writting
				},
			},
		},
		lualine_x = { "encoding", "fileformat" },
		lualine_y = { { "branch", icon = "" } },
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = { telescope_extension },
})
