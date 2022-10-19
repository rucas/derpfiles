local modules = {
	"core.autocmds",
	"core.commands",
	"core.options",
	"core.mappings",
	"core.disable",
	"core.globals",
}

for _, module in ipairs(modules) do
	local ok, err = pcall(require, module)
	if not ok then
		error("Error loading " .. module .. "\n\n" .. err)
	end
end
