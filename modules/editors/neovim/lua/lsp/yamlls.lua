local M = {}

M.setup = function(on_attach, capabilities, handlers)
	require("lspconfig").yamlls.setup({
		settings = {
			yaml = {
				schemaStore = {
					-- You must disable built-in schemaStore support if you want to use
					-- this plugin and its advanced options like `ignore`.
					enable = false,
					-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
					url = "",
				},
				schemas = require("schemastore").yaml.schemas(),
			},
		},
		on_attach = on_attach,
		capabilities = capabilities,
		handlers = handlers,
	})
end

return M
