local utils = require("utils")

-- Leader key
vim.g.mapleader = ","

--utils.map("i", "jk", "<esc>")

-- Use semicolon to enter command mode also
utils.map("n", ";", ":")

-- Move by visual line not actual line
utils.map("n", "j", "gj")
utils.map("n", "k", "gk")

-- Searching --
--
-- Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
utils.map("n", "<space>", "/")
utils.map("n", "<c-space>", "?")

-- Packer --
--
-- Loads async rather than at startup each time
vim.cmd("silent! command PackerClean lua require 'plugins' require('packer').clean()")
vim.cmd("silent! command PackerCompile lua require 'plugins' require('packer').compile()")
vim.cmd("silent! command PackerInstall lua require 'plugins' require('packer').install()")
vim.cmd("silent! command PackerStatus lua require 'plugins' require('packer').status()")
vim.cmd("silent! command PackerSync lua require 'plugins' require('packer').sync()")
vim.cmd("silent! command PackerUpdate lua require 'plugins' require('packer').update()")

-- Nnn ---
utils.map("n", "<leader>nn", "<cmd>NnnPicker<cr>")
utils.map("n", "<leader>nc", "<cmd>NnnPicker %:p:h<cr>")
