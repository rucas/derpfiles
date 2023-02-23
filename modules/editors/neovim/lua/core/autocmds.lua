-- YAML
-- vim.cmd([[ autocmd Filetype yaml setlocal ts=2 sts=2 sw=2 expandtab ]])
vim.api.nvim_create_autocmd("Filetype", {
	pattern = "yaml",
	callback = function()
		vim.cmd([[setlocal ts=2 sts=2 sw=2 expandtab]])
	end,
})

-- Jenkinsfile
-- vim.cmd([[ autocmd BufNewFile,BufRead Jenkinsfile set filetype=groovy ]])
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "Jenkinsfile",
	callback = function()
		vim.bo.filetype = "groovy"
	end,
})

-- ZSH functions
-- vim.cmd([[ autocmd BufNewFile,BufRead **/zsh/zfuncs/* set filetype=zsh ]])
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "**/zsh/zfuncs/*",
	callback = function()
		vim.bo.filetype = "zsh"
	end,
})

-- Alacritty Padding
function IncreasePadding()
	vim.cmd("silent !alacritty msg config 'window.padding.x=45'")
	vim.cmd("silent !alacritty msg config 'window.padding.y=45'")
end

function DecreasePadding()
	vim.cmd("silent !alacritty msg config 'window.padding.x=2'")
	vim.cmd("silent !alacritty msg config 'window.padding.y=2'")
end

vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = "*",
	callback = function()
		DecreasePadding()
	end,
})

vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
	pattern = "*",
	callback = function()
		IncreasePadding()
	end,
})

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
	pattern = "*",
	callback = function(_)
		local ft = vim.bo.filetype
		if ft ~= "toggleterm" then
			vim.wo.cursorline = true
		end
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
	pattern = "*",
	callback = function(_)
		local ft = vim.bo.filetype
		if ft ~= "toggleterm" then
			vim.wo.cursorline = false
		end
	end,
})
