require("auto-save").setup({
	enabled = true,
	execution_message = {
		message = function()
			return (" 💾 saving...")
		end,
		dim = 0.18,
		cleaning_interval = 1250,
	},
	trigger_events = { "InsertLeave", "TextChanged" },
	write_all_buffers = false,
	debounce_delay = 135,
})
