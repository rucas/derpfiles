local colors = require("gruvbox.palette");
require("gruvbox").setup({
    --undercurl = true,
    --underline = true,
    --bold = true,
    --italic = true,
    --strikethrough = true,
    --invert_selection = false,
    --invert_signs = false,
    --invert_tabline = false,
    --invert_intend_guides = false,
    --inverse = true, -- invert background for search, diffs, statuslines and errors
    --contrast = "", -- can be "hard", "soft" or empty string
    --palette_overrides = {},
    overrides = {
      SignColumn = { bg = colors.dark0  },
      --GitSignsCurrentLineBlame = { gui=bold,italic guifg=#ea6962 }
      GitSignsAdd = { bg = colors.dark0, fg=colors.bright_green },
      GitSignsChange = { bg = colors.dark0, fg=colors.bright_aqua },
      GitSignsDelete = { bg = colors.dark0, fg=colors.bright_red },
    },
    --dim_inactive = false,
    --transparent_mode = false,
  })
  vim.cmd("colorscheme gruvbox")