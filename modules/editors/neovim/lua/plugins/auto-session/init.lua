local toggleterm = require("toggleterm")

local function close_floating_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			vim.api.nvim_win_close(win, false)
		end
	end
end

local function close_toggleterm()
    -- NOTE: we do this so we can start in normal mode
    -- toggleterm sets to insertmode start
	toggleterm.toggle_all()
end

local function clear_jumps()
	vim.cmd("clearjumps")
end

require("auto-session").setup({
	log_level = "error",
	pre_save_cmds = { close_floating_windows, close_toggleterm },
	post_restore_cmds = { clear_jumps },
	auto_session_use_git_branch = true,
})
