local colors = require("gruvbox.palette")
local config = require("gruvbox").config

function lsp_overrides()
	require("lspconfig.ui.windows").default_options.border = "single"
end

require("gruvbox").setup({
	undercurl = true,
	underline = true,
	bold = true,
	italic = true,
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
		--["@keyword"] = { link = "GruvboxPurple" },
		--["@keyword.function"] = { link = "GruvboxAqua" },
		--FloatBorder = { fg = colors.dark0, bg = "#3e5751" },
		Pmenu = { fg = "#d4be98", bg = colors.dark0 },
		LspInfoBorder = { fg = colors.gray },
		SignColumn = { bg = colors.dark0 },
		--GitSignsCurrentLineBlame = { gui=bold,italic guifg=#ea6962 }
		GitSignsAdd = { fg = "#545b32", bg = colors.bg0, reverse = config.invert_signs },
		GitSignsChange = { fg = "#3e5751", bg = colors.bg0, reverse = config.invert_signs },
		GitSignsDelete = { fg = "#ea6962", bg = colors.bg0, reverse = config.invert_signs },

		-- StatusLine = { fg = "#d4be98", bg = "#a89984" },
		NvimTreeNormal = { fg = "#d4be98", bg = "#2b2b2b" },
		NvimTreeWinStatusLineNC = { fg = colors.dark0, bg = colors.dark0 },
		NvimTreeWinSeparator = { fg = colors.dark0, bg = colors.dark0 },
	},
	dim_inactive = false,
	transparent_mode = false,
})
vim.cmd([[ autocmd ColorScheme * lua lsp_overrides()]])
vim.cmd("colorscheme gruvbox")
