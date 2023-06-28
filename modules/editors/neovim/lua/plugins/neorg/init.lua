require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.manoeuvre"] = {},
		["core.keybinds"] = {
			config = {
				neorg_leader = "<Leader>",
			},
		},
		["core.dirman"] = {
			config = {
				workspaces = {
					work = "~/Documents/notes/work",
					home = "~/Documents/notes/home",
				},
			},
		},
		["core.concealer"] = {
			config = {
				icons = {
					todo = {
						enabled = true,
						on_hold = {
							icon = "",
						},
						pending = {
							icon = "",
						},
						uncertain = {
							icon = "",
						},
						urgent = {
							icon = "",
						},
						undone = {
							icon = "_",
						},
						cancelled = {
							icon = "ﮊ",
						},
					},
				},
			},
		},
		["core.completion"] = {
			config = {
				engine = "nvim-cmp",
			},
		},
	},
})
