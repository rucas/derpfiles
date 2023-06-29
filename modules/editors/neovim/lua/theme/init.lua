local colors = require("gruvbox.palette").colors
local config = require("gruvbox").config

require("gruvbox").setup({
	undercurl = true,
	underline = true,
	bold = true,
	italic = {
		strings = true,
		comments = true,
		operators = false,
		folds = true,
	},
	strikethrough = true,
	invert_selection = false,
	invert_signs = false,
	invert_tabline = false,
	invert_intend_guides = false,
	inverse = true, -- invert background for search, diffs, statuslines and errors
	contrast = "", -- can be "hard", "soft" or empty string
	palette_overrides = {
		aqua = "#8bba7f",
		light1 = "#d4be98",
		bright_red = "#ea6962",
		neutral_red = "#b85651",
		bright_green = "#a9b665",
		faded_green = "#545b32",
		bright_orange = "#e78a4e",
		bright_yellow = "#d8a657",
		blue = "#7daea3",
		faded_blue = "#3e5751",
	},
	overrides = {
		Pmenu = { fg = "#d4be98", bg = "#2b2b2b" },
		SignColumn = { bg = colors.dark0 },

		--GitSignsCurrentLineBlame = { gui=bold,italic guifg=#ea6962 }
		GitSignsAdd = { fg = "#545b32", bg = colors.dark0, reverse = config.invert_signs },
		GitSignsChange = { fg = "#3e5751", bg = colors.dark0, reverse = config.invert_signs },
		GitSignsDelete = { fg = "#ea6962", bg = colors.dark0, reverse = config.invert_signs },

		WinSeparator = { guibg = nil, fg = "#383838" },

		NvimTreeNormal = { fg = "#d4be98", bg = "#2b2b2b" },
		NvimTreeWinSeparator = { guibg = nil, fg = "#2b2b2b" },
		NvimTreeWindowPicker = { fg = "#ea6962", bg = colors.dark1 },

		NormalFloat = { bg = "#2b2b2b" },
		--FloatBorder = { fg = "#2b2b2b", bg = "#2b2b2b" },
		LspInfoBorder = { bg = "#2b2b2b", fg = nil },

		-- NOTE: this doesnt work for some reason...
		-- see https://github.com/ellisonleao/gruvbox.nvim/issues/138
		-- DiagnosticError = { bg = colors.bg0 },
		-- DiagnosticWarn = { bg = colors.bg0 },
		-- DiagnosticSignHint = { bg = solors.bg0, fg = colors.red },
		-- DiagnosticSignInfo = { bg = colors.bg0, fg = colors.red },
		-- LSP signs
		GruvboxRedSign = { bg = "NONE" },
		GruvboxYellowSign = { bg = "NONE" },
		GruvboxBlueSign = { bg = "NONE" },
		GruvboxAquaSign = { bg = "NONE" },

		-- NOTE: Telescope Highlights
		-- SEE: https://github.com/nvim-telescope/telescope.nvim/blob/master/plugin/telescope.lua
		TelescopeNormal = {
			fg = "#d4be98",
			bg = "#2b2b2b",
		},
		TelescopeBorder = {
			fg = "#2b2b2b",
			bg = "#2b2b2b",
		},
		-- Telescope Prompt: this is where you type in Telescope
		TelescopePromptNormal = {
			fg = "#d4be98",
			bg = colors.dark1,
		},
		TelescopePromptBorder = {
			fg = colors.dark1,
			bg = colors.dark1,
		},
		TelescopePromptTitle = {
			fg = colors.dark1,
			bg = colors.dark1,
		},
		TelescopePromptCounter = {
			fg = colors.dark4,
			bg = colors.dark1,
		},
		TelescopePreviewBorder = {
			fg = "#2b2b2b",
			bg = "#2b2b2b",
		},
		TelescopeResultsBorder = {
			fg = "#2b2b2b",
			bg = "#2b2b2b",
		},
		TelescopeSelection = { bg = "#3e5751", bold = true },
		TelescopeMatching = { fg = "#ea6962" },
		TelescopeResultsTitle = {
			fg = "#2b2b2b",
			bg = "#2b2b2b",
		},
		LineNr = { fg = colors.dark1 },
		CursorLine = { bg = "#303030" },
		CursorLineNr = { fg = colors.dark1, bg = "#303030" },
		FoldColumn = { fg = colors.dark2, bg = colors.dark0 },
	},
	dim_inactive = false,
	transparent_mode = false,
})

-- setup must be called before loading

require("nvim-web-devicons").set_icon({
	md = {
		icon = "",
		color = "#d4be98",
		cterm_color = "white",
		name = "Md",
	},
})

local nvim_web_devicons = require("nvim-web-devicons")
local current_icons = nvim_web_devicons.get_icons()
local new_icons = {}

for key, icon in pairs(current_icons) do
	icon.color = "#d4be98"
	icon.cterm_color = 198
	new_icons[key] = icon
end

nvim_web_devicons.set_icon(new_icons)

vim.cmd("colorscheme gruvbox")
--vim.cmd("colorscheme kanagawa")

-- NOTE: adding other colors to gruvbox
colors["other_dark"] = "#2b2b2b"
