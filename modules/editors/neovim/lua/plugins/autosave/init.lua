local utils = require("auto-save.utils.data")

require("auto-save").setup({
	enabled = true,
	trigger_events = {
		immediate_save = { "BufLeave", "FocusLost" },
		defer_save = { "InsertLeave", "TextChanged" },
		cancel_deferred_save = { "InsertEnter" },
	},
	condition = function(buf)
		if utils.not_in(vim.bo.filetype, { "gitcommit" }) then
			return true
		end
		return false
	end,
	write_all_buffers = false,
	debounce_delay = 135,
})
