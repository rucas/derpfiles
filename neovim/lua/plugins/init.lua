local present, packer = pcall(require, "plugins.packer")

if not present then
	return false
end

local use = packer.use

return packer.startup(function()
	-- this is arranged on the basis of when a plugin starts
	use({
		"wbthomason/packer.nvim",
		event = "VimEnter",
	})

	use({
		"eddyekofo94/gruvbox-flat.nvim",
		after = "packer.nvim",
		event = "VimEnter",
		config = function()
			vim.opt.termguicolors = true
			vim.opt.syntax = "enabled"
			vim.opt.background = "dark"
			vim.g.gruvbox_flat_style = "dark"
			vim.cmd([[colorscheme gruvbox-flat]])
		end,
		requires = {
			"rktjmp/lush.nvim",
		},
	})

	use({
		"nvim-treesitter/nvim-treesitter",
		after = "gruvbox-flat.nvim",
		event = "VimEnter",
		config = function()
			require("plugins.nvim-treesitter")
		end,
	})

	use({
		"p00f/nvim-ts-rainbow",
		after = "nvim-treesitter",
	})

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("plugins.gitsigns")
		end,
		event = "BufEnter",
		requires = {
			"nvim-lua/plenary.nvim",
		},
	})

	use({
		"max397574/better-escape.nvim",
		config = function()
			require("plugins.better-escape")
		end,
	})

	use({
		"lukas-reineke/indent-blankline.nvim",
		after = "gruvbox-flat.nvim",
		config = function()
			require("plugins.indent-blankline")
		end,
		event = "VimEnter",
	})

	use({
		"norcalli/nvim-colorizer.lua",
		after = "gruvbox-flat.nvim",
		config = function()
			require("plugins.nvim-colorizer")
		end,
	})

	use({
		"nvim-telescope/telescope.nvim",
		config = function()
			require("plugins.telescope")
		end,
		requires = {
			{
				"nvim-lua/plenary.nvim",
			},
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				run = "make",
			},
		},
	})

	use({
		"glepnir/dashboard-nvim",
		config = function()
			require("plugins.dashboard-nvim")
		end,
	})

	use({
		"mcchrish/nnn.vim",
		cmd = { "NnnPicker" },
		config = function()
			require("plugins.nnn")
		end,
	})

	use({
		"Pocco81/AutoSave.nvim",
		config = function()
			require("plugins.autosave")
		end,
	})

	use({
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.nvim-lspconfig")
		end,
		requires = {
			{
				"kabouzeid/nvim-lspinstall",
			},
			{
				"ms-jpg/coq_nvim",
			},
		},
	})

	use({
		"ms-jpq/coq_nvim",
		requires = {
			"ms-jpq/coq.artifacts",
		},
	})

	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
	})

	--use {
	--  "windwp/nvim-autopairs",
	--  config = function()
	--    require "plugins.nvim-autopairs"
	--  end,
	--}
	--  --after = "nvim-cmp",
	--}

	use({
		"aserowy/tmux.nvim",
		config = function()
			require("plugins.tmux")
		end,
	})

	use({
		"RRethy/vim-illuminate",
		event = "VimEnter",
		config = function()
			vim.g.Illuminate_delay = 500
		end,
	})

	-- BUG:
	-- TODO:
	-- FIX:
	-- HACK
	-- WARN:
	-- PERF:
	-- NOTE:
	use({
		"folke/todo-comments.nvim",
		event = "VimEnter",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
				signs = false,
			})
		end,
	})
end)