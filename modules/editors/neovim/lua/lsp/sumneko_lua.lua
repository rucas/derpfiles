local M = {}

require("neodev").setup({
	override = function(root_dir, library)
	  if require("neodev.util").has_file(root_dir, "/etc/nixos") then
		library.enabled = true
		library.plugins = true
	  end
	end,
  })

local settings = {
	Lua = {
		diagnostics = {
			globals = {
				"global",
				"vim",
				"use",
				"describe",
				"it",
				"assert",
				"before_each",
				"after_each",
			},
		},
	},
}

M.setup = function(on_attach, capabilities)
	require("lspconfig").sumneko_lua.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = settings,
		flags = {
			debounce_text_changes = 150,
		},
	})
end

return M
