local M = {}

M.setup = function(on_attach, capabilities, handlers)
	require("lspconfig").cssls.setup({
		settings = {
			css = {
				validate = true,
			},
			less = {
				validate = true,
			},
			scss = {
				validate = true,
			},
		},
		on_attach = on_attach,
		capabilities = capabilities,
		handlers = handlers,
	})
end

return M
