local functional = require("utils.functional")
local format = require("utils.format")

local utils = {
	format = format,
	functional = functional,
}

utils.highlight = function(group, fgcolor, bgcolor)
	vim.cmd("highlight " .. group .. " guifg=" .. fgcolor .. " guibg=" .. bgcolor)
end

return utils
