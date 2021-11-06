local is_present_autopairs, autopairs = pcall(require, "nvim-autopairs")
if not is_present_autopairs then
	return
end

autopairs.setup({})
