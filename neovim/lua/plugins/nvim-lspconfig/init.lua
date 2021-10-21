local is_present_lsp_config, lsp_config = pcall(require, "lspconfig")
local is_present_lsp_inst, lsp_install = pcall(require, "lspinstall")
local is_present_coq, coq = pcall(require, "coq")


if not (is_present_lsp_config or is_present_lsp_inst or is_present_coq) then
  error("Error loading " .. "\n\n" .. lsp_config .. lsp_install .. coq)
  return
end


-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- setup illuminate
  require 'illuminate'.on_attach(client)
  
  
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local function setup_servers()
  lsp_install.setup()
  local servers = lsp_install.installed_servers()
  for _, lsp in ipairs(servers) do
    lsp_config[lsp].setup {
      coq.lsp_ensure_capabilities({
        on_attach = on_attach,
        flags = {
          debounce_text_changes = 150,
        }
      })
    }
  end
end


local pyright_config = require"lspinstall/util".extract_config("pyright")
pyright_config.default_config.cmd = {
  '/Users/lucas.rondenet/.nvm/versions/node/v12.18.4/bin/node', 
  '/Users/lucas.rondenet/.local/share/nvim/lspinstall/python/./node_modules/.bin/pyright-langserver', 
  '--stdio' 
}
require'lspinstall/servers'.python = vim.tbl_extend('error', pyright_config, {})

local bash_config = require"lspinstall/util".extract_config("bashls")
bash_config.default_config.cmd = {
  '/Users/lucas.rondenet/.nvm/versions/node/v12.18.4/bin/node', 
  '/Users/lucas.rondenet/.local/share/nvim/lspinstall/bash/node_modules/./.bin/bash-language-server',
  'start' 
}
require'lspinstall/servers'.bash = vim.tbl_extend('error', bash_config, {})

setup_servers()
-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lsp_install.post_install_hook = function ()
  setup_servers()    -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end
