return {
	-- Required fields
	name = "pytest",
	builder = function()
		-- This must return an overseer.TaskDefinition
		local file = vim.fn.expand("%:p")
		return {
			-- cmd is the only required field
			cmd = { "pytest" },
			-- additional arguments for the cmd
			args = { file },
			-- the name of the task (defaults to the cmd of the task)
			name = "pytest",
			-- set the working directory for the task
			-- cwd = "/tmp",
			components = { { "on_output_quickfix", open = true }, "default" },
		}
	end,
	-- Optional fields
	desc = "Run pytest",
	params = {
		-- See :help overseer.params
	},
	-- Determines sort order when choosing tasks. Lower comes first.
	priority = 50,
	-- Add requirements for this template. If they are not met, the template will not be visible.
	-- All fields are optional.
	condition = {
		-- A string or list of strings
		-- Only matches when current buffer is one of the listed filetypes
		filetype = { "python" },
		callback = function()
			if vim.fn.executable("pytest") == 1 then
				return true
			else
				return false
			end
		end,
	},
}
