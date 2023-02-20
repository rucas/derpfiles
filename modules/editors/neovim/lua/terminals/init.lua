local Terminal = require("toggleterm.terminal").Terminal

local gitui = Terminal:new({
	cmd = "gitui",
	dir = "git_dir",
	direction = "float",
	float_opts = {
		width = 175,
		height = 40,
	},
	on_open = function(_) end,
	hidden = true,
})

local procs = Terminal:new({
	cmd = "procs",
	direction = "float",
	hidden = true,
})

local cal = Terminal:new({
	cmd = "cal",
	close_on_exit = false,
	direction = "float",
	hidden = true,
})

local Terms = {}

Terms.gitui = function()
	gitui:toggle()
end

Terms.procs = function()
	procs:toggle()
end

Terms.cal = function()
	cal:toggle()
end

return Terms
