local c = require("configs")

local M = {}

M.setup = function(on_attach, capabilities)
	require("lspconfig").pyright.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = {
			c.NODE_BIN,
			"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/python/node_modules/.bin/pyright-langserver",
			"--stdio",
		},
	})
end

return M
