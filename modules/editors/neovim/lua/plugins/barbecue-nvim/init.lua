require("barbecue").setup({
	create_autocmd = false,
	show_dirname = false,
	show_basename = false,
})

vim.api.nvim_create_autocmd({
	"WinResized",
	"BufWinEnter",
	"CursorHold",
	"InsertLeave",

	-- include these if you have set `show_modified` to `true`
	"BufWritePost",
	"TextChanged",
	"TextChangedI",
}, {
	group = vim.api.nvim_create_augroup("barbecue.updater", {}),
	callback = function()
		require("barbecue.ui").update()
	end,
})
