vim.opt.encoding = "utf8"
-- vim.opt.scriptencoding = 'utf8'

-- A buffer becomes hidden when it is abandoned
vim.opt.hidden = true

-- Node --
--
vim.g.node_host_prog = "/Users/lucas.rondenet/.nvm/versions/node/v12.18.4/bin/node"

-- UI
--
-- Always show current position
vim.opt.ruler = true

-- show line numbers
vim.opt.number = true

-- no status line
vim.opt.laststatus = 0

-- Mouse for all modes (visual, normal, insert, command line)
vim.opt.mouse = "a"

-- Searching
--
-- Ignore case when searching
vim.opt.ignorecase = true

-- When searching try to be smart about cases
vim.opt.smartcase = true

-- Makes search act like search in modern browsers
vim.opt.incsearch = true

-- For regular expressions turn magic on
vim.opt.magic = true

-- Show matching brackets when text indicator is over them
vim.opt.showmatch = true

-- How many tenths of a second to blink when matching brackets
vim.opt.matchtime = 2

-- Ignore compiled files
vim.opt.wildignore = "*.o,*~,*.pyc"

-- Files, backups, and undo
--
-- no backup
vim.opt.backup = false

-- no swap file
vim.opt.swapfile = false

-- no undo
vim.opt.undofile = false

-- Don't redraw while executing macros (good performance config)
vim.opt.lazyredraw = true

-- Text, Tabs and indents
--
-- Use spaces instead of tabs
vim.opt.expandtab = true

-- Be smart when using tabs ;)
vim.opt.smarttab = true

-- 1 tab == 4 spaces
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Linebreak on 80 characters
vim.opt.linebreak = true
vim.opt.textwidth = 80

-- autoindent, smart, and wrap it up
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true

-- TODO:
vim.opt.timeoutlen = 500
vim.opt.updatetime = 500