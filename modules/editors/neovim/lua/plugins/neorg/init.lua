require("neorg").setup({
	load = {
		["core.defaults"] = {},
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
				folds = true,
				init_open_folds = "never",
				icons = {
					code_block = { conceal = true },
					todo = {
						cancelled = {
							icon = "",
						},
						done = {
							icon = "",
						},
						on_hold = {
							icon = "",
						},
						pending = {
							icon = "",
						},
						recurring = {
							icon = "",
						},
						uncertain = {
							icon = "",
						},
						undone = {
							icon = "",
						},
						urgent = {
							icon = "",
						},
					},
					heading = {
						icons = { "◉", "◎", "○", "⊛", "¤", "∘" },
					},
				},
			},
		},
		["core.completion"] = {
			config = {
				engine = "nvim-cmp",
			},
		},
		["core.presenter"] = {
			config = {
				zen_mode = "zen-mode",
			},
		},
		["core.ui.calendar"] = {},
	},
})
