local M = {}

M.setup = function(on_attach, capabilities, handlers)
	require("lspconfig").ts_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		handlers = handlers,
		root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
	})
end

return M
