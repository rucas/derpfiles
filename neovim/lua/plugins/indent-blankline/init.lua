local present, bl_config = pcall(require, "indent_blankline")
if not present then
  return
end

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab:› ")
vim.opt.listchars:append("trail:•")
--listchars = [[tab:› ,trail:•,extends:#,nbsp:.]]

bl_config.setup {
  filetype_exclude = {
    "help",
    "terminal",
    "dashboard",
    "packer",
    "lspinfo",
    "TelescopePrompt",
    "TelescopeResults",
  },
  buftype_exclude = { "terminal" },
  space_char_blankline = " ",
  show_current_context = true,
  show_first_indent_level = false,
  show_trailing_blankline_indent = false,
  show_end_of_line = true,
}
