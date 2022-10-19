-- TODO: figure out how to do grouping of auto commands

local u = require("utils")

-- YAML
vim.cmd([[ autocmd Filetype yaml setlocal ts=2 sts=2 sw=2 expandtab ]])

-- Jenkinsfile
vim.cmd([[ autocmd BufNewFile,BufRead Jenkinsfile set filetype=groovy ]])

-- ZSH functions
vim.cmd([[ autocmd BufNewFile,BufRead **/zsh/zfuncs/* set filetype=zsh ]])

-- Alacritty Padding
function IncreasePadding()
	u.format.sed("50", 0, 10, "~/.alacritty.yml")
	u.format.sed("51", 0, 10, "~/.alacritty.yml")
end

function DecreasePadding()
	u.format.sed("50", 10, 0, "~/.alacritty.yml")
	u.format.sed("51", 10, 0, "~/.alacritty.yml")
end

--vim.cmd([[
--  augroup AlacrittyPadding
--   au!
--   au VimEnter * lua DecreasePadding()
--   au VimLeavePre * lua IncreasePadding()
--  augroup END
--]])

-- set cursorline only on active buffer
vim.cmd([[
    augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
    augroup END
]])
