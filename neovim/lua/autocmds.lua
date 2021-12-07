-- TODO: figure out how to do grouping of auto commands

-- YAML
vim.cmd([[ autocmd Filetype yaml setlocal ts=2 sts=2 sw=2 expandtab ]])

-- Jenkinsfile
vim.cmd([[ autocmd BufNewFile,BufRead Jenkinsfile set filetype=groovy ]])
