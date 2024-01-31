--local terms = require("terminals")

-- Leader key
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

-- Use semicolon to enter command mode also
vim.keymap.set("n", ";", ":")

-- Exit hard and fast!
vim.keymap.set("n", "ZZ", ":w | qa<CR>", { silent = true })

-- NOTE: os specific might be "*y
-- send to os specific copy-paste
vim.keymap.set("v", "YY", '"+y')

-- window panes
--
vim.keymap.set({ "n" }, "<C-k>", "<cmd>wincmd k<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<C-j>", "<cmd>wincmd j<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<C-h>", "<cmd>wincmd h<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<C-l>", "<cmd>wincmd l<cr>", { noremap = true, silent = true })

-- neogen

vim.keymap.set({ "n" }, "<Leader>nc", "<cmd>Neogen class<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>nf", "<cmd>Neogen func<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>nF", "<cmd>Neogen file<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>nt", "<cmd>Neogen type<cr>", { noremap = true, silent = true })

-- buffers
--
vim.keymap.set({ "n" }, "<Leader>bd", "<cmd>bp | bd #<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>bD", "<cmd>bd<cr>", { noremap = true, silent = true })

-- files
--
vim.keymap.set({ "n" }, "<Leader>ft", "<cmd>NvimTreeToggle<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>fg", "<cmd>Telescope git_files<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>fo", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })

-- project
--
vim.keymap.set({ "n" }, "<Leader>ps", "<cmd>SearchSession<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>pw", "<cmd>SaveSession<cr>", { noremap = true, silent = true })

-- terminal
--
vim.keymap.set({ "n" }, "<Leader>tg", function()
	require("terminals").gitui()
end, { noremap = true, silent = true })

vim.keymap.set({ "n" }, "<Leader>tp", function()
	require("terminals").procs()
end, { noremap = true, silent = true })

-- search
--
vim.keymap.set({ "n" }, "<Leader>/", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })

-- lsp
--
vim.keymap.set({ "n" }, "<Leader>lc", vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>ld", vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>lD", vim.lsp.buf.declaration, { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>li", "<cmd>Telescope lsp_implementations<cr>", { noremap = true, silent = true })
vim.keymap.set(
	{ "n" },
	"<Leader>lr",
	"<cmd>Telescope lsp_references show_line=false<cr>",
	{ noremap = true, silent = true }
)
vim.keymap.set({ "n" }, "<Leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>lw", "<cmd>Telescope lsp_workspace_symbols<cr>", { noremap = true, silent = true })
vim.keymap.set(
	{ "n" },
	"<Leader>lx",
	"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
	{ noremap = true, silent = true }
)
vim.keymap.set({ "n" }, "<Leader>ln", vim.lsp.buf.rename, { noremap = true, silent = true })
