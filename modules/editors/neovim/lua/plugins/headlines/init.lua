require("headlines").setup({
	markdown = {
		headline_highlights = {
			"Headline1",
			"Headline2",
			"Headline3",
			"Headline4",
			"Headline5",
			"Headline6",
		},
		--codeblock_highlight = "CodeBlock",
		fat_headlines = false,
	},
	yaml = {
		dash_pattern = "^---+$",
		dash_highlight = "Dash",
	},
})

--vim.cmd([[highlight Headline1 guifg=#000000 guibg=#76a065]])
--vim.cmd([[highlight Headline2 guibg=#cf8164]])
--vim.cmd([[highlight Headline3 guibg=#ab924c]])
--vim.cmd([[highlight Headline4 guibg=#2e313d]])
--vim.cmd([[highlight Headline5 guibg=#272935]])
--vim.cmd([[highlight Headline6 guibg=#20222d]])
--
--vim.cmd([[highlight CodeBlock guibg=#2e313d]])
--vim.cmd([[highlight Dash guibg=#D19A66 gui=bold]])
