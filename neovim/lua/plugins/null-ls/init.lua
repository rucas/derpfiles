local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local sources = {
	null_ls.builtins.formatting.stylua,
	null_ls.builtins.formatting.black.with({ command = "/Users/lucas.rondenet/.pyenv/versions/neovim0.5/bin/black" }),
	null_ls.builtins.formatting.isort.with({ command = "/Users/lucas.rondenet/.pyenv/versions/neovim0.5/bin/isort" }),
	null_ls.builtins.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
}

local M = {}
M.setup = function(on_attach)
	null_ls.config({
		-- debug = true,
		sources = sources,
	})
	require("lspconfig")["null-ls"].setup({ on_attach = on_attach })
end

return M
