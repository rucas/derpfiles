local config = function()
	local saved_terminal
	return {
		window = {
			open = "alternate",
		},
		callbacks = {
			pre_open = function()
				local term = require("toggleterm.terminal")
				local termid = term.get_focused_id()
				saved_terminal = term.get(termid)
			end,
			post_open = function(bufnr, winnr, ft, is_blocking)
				if is_blocking and saved_terminal then
					-- Hide the terminal while it's blocking
					saved_terminal:close()
				end
				-- NOTE: automatically delete buffer on save
				if ft == "gitcommit" or ft == "gitrebase" then
					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = bufnr,
						once = true,
						callback = vim.schedule_wrap(function()
							vim.api.nvim_buf_delete(bufnr, {})
						end),
					})
				end
			end,
			block_end = function()
				-- After blocking ends (for a git commit, etc), reopen the terminal
				vim.schedule(function()
					require("terminals").gitui()
				end)
			end,
		},
	}
end

require("flatten").setup(config())
