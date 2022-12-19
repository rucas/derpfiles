local is_present_todo, todo = pcall(require, "todo-comments")
if not is_present_todo then
	return
end

-- FIX:
-- TODO:
-- HACK:
-- WARN:
-- PERF:
-- NOTE:
-- TEST:
todo.setup({
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
