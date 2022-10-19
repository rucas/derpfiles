-- JSON --
--
vim.cmd([[ command! JSONFormat %! jq . ]])

-- Packer --
--
-- Loads async rather than at startup each time
vim.cmd("silent! command PackerClean lua require 'plugins' require('packer').clean()")
vim.cmd("silent! command PackerCompile lua require 'plugins' require('packer').compile()")
vim.cmd("silent! command PackerInstall lua require 'plugins' require('packer').install()")
vim.cmd("silent! command PackerStatus lua require 'plugins' require('packer').status()")
vim.cmd("silent! command PackerSync lua require 'plugins' require('packer').sync()")
vim.cmd("silent! command PackerUpdate lua require 'plugins' require('packer').update()")
