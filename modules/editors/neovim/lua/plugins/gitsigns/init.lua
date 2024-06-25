require("gitsigns").setup({
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = {
			text = "_",
			show_count = true,
		},
		topdelete = {
			text = "‾",
			show_count = true,
		},
		changedelete = {
			text = "~",
			show_count = true,
		},
		untracked = { text = "┃" },
	},
	current_line_blame = false,
	current_line_blame_formatter = " <author> • <author_time:%R> • <summary>",
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1,
		ignore_whitespace = false,
	},
	count_chars = {
		[1] = "1",
		[2] = "2",
		[3] = "3",
		[4] = "4",
		[5] = "5",
		[6] = "6",
		[7] = "7",
		[8] = "8",
		[9] = "9",
		["+"] = "",
	},
	trouble = false,
})
