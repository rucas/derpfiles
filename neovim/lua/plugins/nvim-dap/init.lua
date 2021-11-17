local utils = require("utils")
local present, dap = pcall(require, "dap")

if not present then
	return
end

require("nvim-dap-virtual-text").setup()

dap.adapters.python = {
	type = "executable",
	command = "/Users/lucas.rondenet/.pyenv/versions/neovim0.5/bin/python",
	args = { "-m", "debugpy.adapter" },
}

utils.map("n", "<leader>dct", "<cmd>lua require('dap').continue()<cr>")
utils.map("n", "<leader>dsv", "<cmd>lua require('dap').step_over()<cr>")
utils.map("n", "<leader>dsi", "<cmd>lua require('dap').step_into()<cr>")
utils.map("n", "<leader>dso", "<cmd>lua require('dap').step_out()<cr>")
utils.map("n", "<leader>dtb", "<cmd>lua require('dap').toggle_breakpoint()<cr>")
utils.map("n", "<leader>dsc", "<cmd>lua require('dap.ui.variables').scopes()<cr>")
utils.map("n", "<leader>dhh", "<cmd>lua require('dap.ui.variables').hover()<cr>")
utils.map("n", "<leader>dhv", "<cmd>lua require('dap.ui.varables').visual_hover()<cr>")
utils.map("n", "<leader>duh", "<cmd>lua require('dap.ui.widgets').hover()<cr>")
utils.map("n", "<leader>dsbr", '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
utils.map(
	"n",
	"<leader>dsbm",
	'<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>'
)
utils.map("n", "<leader>dro", '<cmd>lua require"dap".repl.open()<CR>')
utils.map("n", "<leader>drl", '<cmd>lua require"dap".repl.run_last()<CR>')

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		--program = "${file}",
		program = "${workspaceFolder}/${file}",
		--pythonPath = function()
		--	return "/usr/bin/python"
		--end,
	},
}
