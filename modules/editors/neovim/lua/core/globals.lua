-- NOTE: Does this even work anymore? lol...
function _G.reload_nvim_conf()
	for name, _ in pairs(package.loaded) do
		if name:match("^core") or name:match("^lsp") or name:match("^plugins") or name:match("^utils") then
			package.loaded[name] = nil
		end
	end

	dofile(vim.env.MYVIMRC)
	--package.loaded["plugins"] = nil
	require("plugins")
	vim.cmd("PackerCompile")
	vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

-- NOTE: SETS nvr for gitui
vim.env.GIT_EDITOR = "nvr -cc split --remote-wait"
