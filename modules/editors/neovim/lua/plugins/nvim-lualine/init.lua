local colors = require("gruvbox.palette")

local NvimTree = {
	function()
		return string.rep(" ", require("nvim-tree").config.view.width - 1)
	end,
	cond = require("nvim-tree.view").is_visible,
	padding = { left = 0, right = 0 },
	color = { fg = colors.light1, bg = colors.other_dark },
}

local ViMode = {
	function()
		return ""
	end,
	color = function()
		local mode_color = {
			n = colors.neutral_red,
			i = colors.neutral_green,
			v = colors.blue,
			[""] = colors.blue,
			V = colors.blue,
			c = colors.bright_red,
			no = colors.red,
			s = colors.orange,
			S = colors.orange,
			[""] = colors.orange,
			ic = colors.yellow,
			R = colors.violet,
			Rv = colors.violet,
			cv = colors.red,
			ce = colors.red,
			r = colors.cyan,
			rm = colors.cyan,
			["r?"] = colors.cyan,
			["!"] = colors.red,
			t = colors.bright_purple,
		}
		return { fg = mode_color[vim.fn.mode()] }
	end,
}

local telescope_extension = {
	sections = {
		lualine_a = { NvimTree },
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = { { "branch", icon = "" } },
		lualine_z = {},
	},
	filetypes = { "TelescopePrompt", "TelescopeResults" },
}

local toggleterm_extension = {
	sections = {
		lualine_a = { NvimTree },
		lualine_b = {
			ViMode,
			{
				function()
					return "TERM"
				end,
				color = { gui = "italic,bold" },
			},
		},
		lualine_c = {},
		lualine_x = {},
		lualine_y = { { "branch", icon = "" } },
		lualine_z = {},
	},
	filetypes = { "toggleterm" },
}

local nvimtree_extension = {
	sections = {
		lualine_a = { NvimTree },
		lualine_b = {
			ViMode,
			{
				function()
					return "NVIMTREE"
				end,
				color = { gui = "italic,bold" },
			},
		},
		lualine_c = {},
		lualine_x = {},
		lualine_y = { { "branch", icon = "" } },
		lualine_z = {},
	},
	filetypes = { "NvimTree" },
}

local gruvybox = require("lualine.themes.gruvbox-material")
gruvybox.normal.a.bg = colors.other_dark
gruvybox.normal.b.bg = colors.other_dark
gruvybox.normal.c.bg = colors.other_dark
gruvybox.visual.a.bg = colors.other_dark
gruvybox.insert.a.bg = colors.other_dark
gruvybox.inactive.a.bg = colors.other_dark
gruvybox.command.a.bg = colors.other_dark
gruvybox.replace.a.bg = colors.other_dark

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
		ignore_focus = {
			-- "NvimTree",
			-- "toggleterm",
		},
		always_divide_middle = true,
		globalstatus = true,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { NvimTree },
		lualine_b = { ViMode },
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
	extensions = {
		telescope_extension,
		toggleterm_extension,
		nvimtree_extension,
	},
})
