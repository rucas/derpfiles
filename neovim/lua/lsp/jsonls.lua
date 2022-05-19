local c = require("configs")

local M = {}

M.setup = function(on_attach, capabilities)
	require("lspconfig").jsonls.setup({
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
			},
		},
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = {
			c.NODE_BIN,
			"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/jsonls/node_modules/.bin/vscode-json-language-server",
			"--stdio",
		},
	})
end

return M
