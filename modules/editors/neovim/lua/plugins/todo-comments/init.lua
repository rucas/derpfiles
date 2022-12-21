-- FIX:
-- TODO:
-- HACK:
-- WARN:
-- PERF:
-- NOTE:
-- TEST:
require("todo-comments").setup({
	signs = false,
	highlight = {
		before = "",
		keyword = "wide_bg"
	},
    keywords = {
        FIX = { color = "#ea6962" },
        TODO = { color = "#e78a4e" },
        HACK = { color = "#d8a657" },
        WARN = { color = "#a9b665" },
        PERF = { color = "#89b482" },
        NOTE = { color = "#7daea3" },
        TEST = { color = "#d3869b" }
    }
})
