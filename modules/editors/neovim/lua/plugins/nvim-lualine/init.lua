local palette = require("gruvbox").palette
local api = require("nvim-tree.api")

local colors = palette
local Event = api.events.Event
local nvimTreeWidth = 0

-- NOTE: this keeps lualine in place when moving nvim-tree around
api.events.subscribe(Event.Resize, function(size)
	nvimTreeWidth = size
	require("lualine").refresh({
		place = { "statusline" },
	})
end)

local NvimTree = {
	function()
		if nvimTreeWidth == 0 then
			local nvimtree_view = require("nvim-tree.view")
			local nvimtree_width = vim.fn.winwidth(nvimtree_view.get_winnr())
			nvimTreeWidth = nvimtree_width
		end
		return string.rep(" ", nvimTreeWidth)
	end,
	cond = require("nvim-tree.view").is_visible,
	padding = { left = 0, right = 0 },
	color = { fg = colors.other_dark, bg = colors.other_dark },
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

local ScrollBar = {
	function()
		local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
		local curr_line = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_line_count(0)
		local i = math.floor((curr_line - 1) / lines * #sbar) + 1
		return string.rep(sbar[i], 2)
	end,
	color = { fg = colors.faded_blue, bg = colors.other_dark },
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

-- TODO add back filename winbar...idk where it went
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = gruvybox,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
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
		lualine_x = { ScrollBar, { "location", color = { fg = colors.neutral_green, bg = colors.other_dark } } },
		lualine_y = { "fileformat" },
		lualine_z = { { "branch", icon = "", color = { fg = colors.light1, bg = colors.other_dark } } },
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
