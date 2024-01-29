require("autolist").setup({})

vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")
