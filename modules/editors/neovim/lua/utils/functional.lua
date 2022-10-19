local M = {}

M.map = function(tbl, f)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = f(v)
	end
	return t
end

local function test(n)
	n = n + 1
	print(n)
end

return M
