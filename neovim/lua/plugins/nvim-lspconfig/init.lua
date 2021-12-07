local is_present_lsp_config, lsp_config = pcall(require, "lspconfig")
local is_present_lsp_inst, lsp_install = pcall(require, "nvim-lsp-installer")
local is_present_coq, coq = pcall(require, "coq")

if not (is_present_lsp_config or is_present_lsp_inst or is_present_coq) then
	error("Error loading " .. "\n\n" .. lsp_config .. lsp_install .. coq)
	return
end

-- NOTE: need to do nvm use stable to get npm...and node...
local servers = {
	"bashls",
	"dockerls",
	"pyright",
	"sumneko_lua",
}

for _, name in pairs(servers) do
	local ok, server = lsp_install.get_server(name)
	-- Check that the server is supported in nvim-lsp-installer
	if ok then
		if not server:is_installed() then
			print("Installing " .. name)
			server:install()
		end
	end
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- setup illuminate
	require("illuminate").on_attach(client)

	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	-- Enable completion triggered by <c-x><c-o>
	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	local opts = { noremap = true, silent = true }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	--buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
	buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
	buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

lsp_install.on_server_ready(function(server)
	-- Specify the default options which we'll use for pyright and solargraph
	-- Note: These are automatically setup from nvim-lspconfig.
	-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

	local default_opts = coq.lsp_ensure_capabilities({
		on_attach = on_attach,
		flags = {
			debounce_text_changes = 150,
		},
	})

	-- Now we'll create a server_opts table where we'll specify our custom LSP server configuration
    local node_bin = "/Users/lucas.rondenet/.nvm/versions/node/v16.13.1/bin/node"
	local server_opts = {
		["bashls"] = function()
			default_opts.cmd = {
				node_bin,
				"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/bash/node_modules/.bin/bash-language-server",
				"start",
			}
		end,
		["pyright"] = function()
			default_opts.cmd = {
                node_bin,
				"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/python/node_modules/.bin/pyright-langserver",
				"--stdio",
			}
		end,
        ["dockerls"] = function()
            default_opts.cmd = {
                node_bin,
				"/Users/lucas.rondenet/.local/share/nvim/lsp_servers/dockerfile/node_modules/.bin/docker-langserver",
				"--stdio",
			}
        end,
		["sumneko_lua"] = function()
			default_opts.settings = {
				Lua = {
					runtime = {
						-- LuaJIT in the case of Neovim
						version = "LuaJIT",
						path = vim.split(package.path, ";"),
					},
					diagnostics = {
						-- Get the language server to recognize the `vim` global
						globals = { "vim" },
					},
					workspace = {
						-- Make the server aware of Neovim runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
						},
					},
				},
			}
		end,
	}

	-- We check to see if any custom server_opts exist for the LSP server, if so, load them, if not, use our default_opts
	server:setup(server_opts[server.name] and server_opts[server.name]() or default_opts)
	vim.cmd([[ do User LspAttachBuffers ]])
end)

require("plugins/null-ls").setup(on_attach)
