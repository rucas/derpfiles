local Terminal = require("toggleterm.terminal").Terminal

local gitui = Terminal:new({
	cmd = "gitui",
	direction = "float",
	float_opts = {
		width = 175,
		height = 40,
	},
	hidden = true,
})

local Terms = {}

Terms.gitui = function()
	gitui:toggle()
end

return Terms
