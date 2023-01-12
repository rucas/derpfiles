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

vim.cmd([[
  augroup AlacrittyPadding
   au!
   au VimEnter * lua DecreasePadding()
   au VimLeavePre * lua IncreasePadding()
  augroup END
]])

-- set cursorline only on active buffer
vim.cmd([[
    augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
    augroup END
]])

-- Navigate out of toggle terminal
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*toggleterm#*",
	callback = function()
		vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<CR>", { buffer = 0, silent = true })
		vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<CR>", { buffer = 0, silent = true })
	end,
})
