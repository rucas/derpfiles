local null_ls = require("null-ls")

local sources = {
	null_ls.builtins.formatting.trim_whitespace,
	null_ls.builtins.formatting.trim_newlines,
	null_ls.builtins.formatting.stylua,
	null_ls.builtins.formatting.nixfmt,
	null_ls.builtins.code_actions.statix,
	null_ls.builtins.formatting.black,
	null_ls.builtins.formatting.isort,
	null_ls.builtins.diagnostics.flake8,
	null_ls.builtins.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
}

local M = {}

M.setup = function(on_attach)
	null_ls.setup({
		-- NOTE:
		-- debug = true,
		sources = sources,
		on_attach = on_attach,
	})
end

return M
