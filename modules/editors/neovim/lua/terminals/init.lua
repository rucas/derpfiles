local Terminal = require("toggleterm.terminal").Terminal
local gitui = Terminal:new({ cmd = "gitui", hidden = true })

local Terms = {}

Terms.gitui = function()
	gitui:toggle()
end

return Terms
