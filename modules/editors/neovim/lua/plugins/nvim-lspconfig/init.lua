local illuminate = require("illuminate")

-- LSP Diagnostics
vim.diagnostic.config({
	underline = true,
	update_in_insert = true,
	virtual_text = {
		spacing = 4,
		prefix = "●",
		format = function(diagnostic)
			return string.format("%s: %s", diagnostic.source, diagnostic.message)
		end,
	},
	severity_sort = true,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
--local opts = { noremap = true, silent = true }
--vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
--vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
--vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
--vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- setup illuminate
	illuminate.on_attach(client)

	-- Enable completion triggered by <c-x><c-o>
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "<space>sh", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)

	-- LSP diagnostic popup
	vim.api.nvim_create_autocmd({ "CursorHold" }, {
		buffer = bufnr,
		callback = function()
			vim.diagnostic.open_float(nil, {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			})
		end,
	})
end

-- LSPINFO UI
require("lspconfig.ui.windows").default_options.border = "rounded"

-- LSP settings (for overriding per client)
local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
}

local servers = {
	"bashls",
	"cssls",
	"dockerls",
	"jsonls",
	"lua_ls",
	"marksman",
	"nil_ls",
	"pyright",
	"terraform-ls",
	"tsserver",
	"yamlls",
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()
for _, server in ipairs(servers) do
	require("lsp." .. server).setup(on_attach, capabilities, handlers)
end
