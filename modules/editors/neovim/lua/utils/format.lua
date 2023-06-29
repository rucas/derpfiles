local M = {}

M.sed = function(line_nr, from, to, fname)
	vim.cmd(string.format("silent !gsed -i '%ss/%s/%s/' %s", line_nr, from, to, fname))
end

return M
