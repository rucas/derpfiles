local utils = require("auto-save.utils.data")

require("auto-save").setup({
	enabled = true,
	execution_message = { enabled = false },
	trigger_events = {
		immediate_save = { "BufLeave", "FocusLost" },
		defer_save = { "InsertLeave", "TextChanged" },
		cancel_defered_save = { "InsertEnter" },
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
