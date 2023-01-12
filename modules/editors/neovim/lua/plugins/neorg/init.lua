require("neorg").setup({
	load = {
		["core.defaults"] = {},
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
							icon = "",
							--icon = "",
						},
						uncertain = {
							icon = "",
						},
						urgent = {
							icon = "",
						},
						undone = {
							icon = "",
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
		["core.norg.manoeuvre"] = {},
	},
})
