local present, neorg = pcall(require, "neorg")
if not present then
	return
end

neorg.setup({
	load = {
		["core.defaults"] = {},
		["core.norg.dirman"] = {
			config = {
				workspaces = {
					work = "~/notes/work",
					home = "~/notes/home",
					gtd = "~/notes/gtd",
				},
			},
		},
		["core.keybinds"] = {
			config = {
				default_keybinds = true,
				--neorg_leader = "<Space>",
				hook = function(keybinds)
					print("FFFFFFFFFFFFFFF")
					--keybinds.map("norg", "n", "ee", "<cmd>echo 'Hello!'<CR>")
					--keybinds.remap("norg", "n", "JJ", "core.norg.manoeuvre.item_down")
					--keybinds.remap_event("norg", "n", "ee", "core.norg.manoeuvre.item_up")
					keybinds.map("norg", "n", "ee", "core.manoeuvre.item_up")
				end,
			},
		},
		["core.norg.concealer"] = {},
		["core.norg.manoeuvre"] = {},
		["core.norg.qol.toc"] = {},
		["core.gtd.base"] = {
			config = {
				workspace = "gtd",
			},
		},
		["core.gtd.ui"] = {},
		["core.gtd.helpers"] = {},
		["core.gtd.queries"] = {},
	},
})
