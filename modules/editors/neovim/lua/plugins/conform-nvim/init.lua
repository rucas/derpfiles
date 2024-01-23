require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettierd", "prettier" },
		json = { "jq" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		python = { "isort", "black" },
		sh = { "shellcheck" },
		toml = { "taplo" },
		["*"] = { "trim_whitespace" },
	},
	-- log_level = vim.log.levels.TRACE,
})
