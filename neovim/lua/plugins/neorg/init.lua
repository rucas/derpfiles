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
				},
			},
		},
		["core.norg.concealer"] = {},
	},
})
