local c = require("configs")

local M = {}

M.setup = function(on_attach, capabilities)
	require("lspconfig").dockerls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = {
			c.NODE_BIN,
			"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/dockerfile/node_modules/.bin/docker-langserver",
			"--stdio",
		},
	})
end

return M
