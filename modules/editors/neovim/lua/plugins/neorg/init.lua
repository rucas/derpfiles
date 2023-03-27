require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.norg.manoeuvre"] = {},
		["core.keybinds"] = {
			config = {
				neorg_leader = "<Leader>",
			},
		},
		["core.norg.dirman"] = {
			config = {
				workspaces = {
					work = "~/Documents/notes/work",
					home = "~/Documents/notes/home",
				},
			},
		},
		["core.norg.concealer"] = {
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
		["core.norg.completion"] = {
			config = {
				engine = "nvim-cmp",
			},
		},
	},
})
