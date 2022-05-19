local c = require("configs")

local M = {}

M.setup = function(on_attach, capabilities)
	require("lspconfig").bashls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
        cmd = {
			c.NODE_BIN,
			"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/bashls/node_modules/.bin/bash-language-server",
			"start",
		},
	})
end

return M
