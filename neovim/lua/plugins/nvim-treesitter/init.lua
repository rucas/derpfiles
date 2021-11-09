local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then
	return
end

ts_config.setup({
	--autopairs = {
	--	enable = true
	--},
	ensure_installed = "maintained",
	indent = {
		enable = true,
	},
	highlight = {
		enable = true,
		use_languagetree = true,
	},
	rainbow = {
		enable = true,
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
	},
})
