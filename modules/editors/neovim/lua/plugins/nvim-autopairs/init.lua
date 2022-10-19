local ok, autopairs = pcall(require, "nvim-autopairs")
if not ok then
	return
end

autopairs.setup({
	fast_wrap = {
		chars = { "{", "[", "(", '"', "'", "`" },
		map = "<C-l>",
		keys = "asdfghjklqwertyuiop",
		pattern = string.gsub([[ [%'%"%)%,>%]%)%}%,%:] ]], "%s+", ""),
		check_comma = true,
		end_key = "$",
		highlight = "Search",
		hightlight_grey = "Comment",
	},
	check_ts = true,
	enable_check_bracket_line = true,
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on(
	"confirm_done",
	cmp_autopairs.on_confirm_done({
		map_char = {
			tex = "",
		},
	})
)
