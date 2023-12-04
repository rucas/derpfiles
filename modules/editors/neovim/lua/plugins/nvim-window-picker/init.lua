local palette = require("gruvbox").palette
local colors = palette

require("window-picker").setup({
	show_prompt = false,
	picker_config = {
		statusline_winbar_picker = {
			use_winbar = "smart",
		},
	},
	highlights = {
		statusline = {
			focused = {
				fg = colors.bright_red,
				bg = colors.other_dark,
				bold = true,
			},
			unfocused = {
				fg = colors.neutral_red,
				bg = colors.other_dark,
				bold = true,
			},
		},
		winbar = {
			focused = {
				fg = colors.bright_red,
				bg = colors.other_dark,
				bold = true,
			},
			unfocused = {
				fg = colors.neutral_red,
				bg = colors.other_dark,
				bold = true,
			},
		},
	},
})
