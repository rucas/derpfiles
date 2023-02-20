local nvim_tree = require("nvim-tree")

local function restore_nvim_tree()
	nvim_tree.toggle(false, true)
end

require("auto-session").setup({
	log_level = "error",
	post_restore_cmds = { restore_nvim_tree },
	auto_session_use_git_branch = true,
})
