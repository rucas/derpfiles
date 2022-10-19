local ok, rest = pcall(require, "rest-nvim")
if not ok then
	return
end
rest.setup({})
