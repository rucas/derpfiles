local M = {}

M.setup = function(on_attach, capabilities, handlers)
	require("lspconfig").terraformls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		handlers = handlers,
	})
end

return M
