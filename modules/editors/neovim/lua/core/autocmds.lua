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

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.md", "*.norg" },
	callback = function()
		vim.bo.textwidth = 80
		vim.bo.wrapmargin = 0
		vim.bo.formatoptions = vim.bo.formatoptions .. "t"
		vim.cmd([[setlocal linebreak]])
	end,
})

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "TelescopePrompt",
	callback = function()
		vim.cmd([[setlocal nocursorline]])
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
		if not (ft == "toggleterm" or ft == "NvimTree") then
			vim.wo.cursorline = true
		end
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
	pattern = "*",
	callback = function(_)
		local ft = vim.bo.filetype
		if not (ft == "toggleterm" or ft == "NvimTree") then
			vim.wo.cursorline = false
		end
	end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
	pattern = "*",
	callback = function(_)
		vim.cmd([[setlocal nonumber norelativenumber]])
	end,
})

-- NOTE: fix for auto-session
-- This autocmd will check whether nvim-tree is open when the session is restored and refresh it.
-- SEE: https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#workaround-when-using-rmagattiauto-session
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "NvimTree*",
	callback = function()
		local view = require("nvim-tree.view")
		local is_visible = view.is_visible()

		local api = require("nvim-tree.api")
		if not is_visible then
			api.tree.open()
		end
	end,
})
