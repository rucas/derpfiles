local utils = require("auto-save.utils.data")

require("auto-save").setup({
	enabled = true,
	execution_message = {
		message = "",
	},
	trigger_events = { "InsertLeave", "TextChanged" },
	condition = function(buf)
		if utils.not_in(vim.bo.filetype, { "gitcommit" }) then
			return true
		end
		return false
	end,
	write_all_buffers = false,
	debounce_delay = 135,
})
