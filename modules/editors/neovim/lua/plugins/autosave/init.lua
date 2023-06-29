require("auto-save").setup({
	enabled = true,
	execution_message = {
		message = "",
	},
	trigger_events = { "InsertLeave", "TextChanged" },
	write_all_buffers = false,
	debounce_delay = 135,
})
