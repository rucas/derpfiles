local function restore_nvim_tree()
	local nvim_tree = require("nvim-tree")
	nvim_tree.toggle(false, true)
end

require("auto-session").setup({
	log_level = "error",
	post_restore_cmds = { restore_nvim_tree },
})
