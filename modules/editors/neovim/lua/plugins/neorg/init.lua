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
						cancelled = {
							icon = "󰚌",
						},
						done = {
							icon = "",
						},
						on_hold = {
							icon = "",
						},
						pending = {
							icon = "",
						},
						recurring = {
							icon = "",
						},
						uncertain = {
							icon = "",
						},
						undone = {
							icon = " ",
						},
						urgent = {
							icon = "",
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
