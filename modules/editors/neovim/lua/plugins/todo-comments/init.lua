local is_present_todo, todo = pcall(require, "todo-comments")
if not is_present_todo then
	return
end

todo.setup({
	--highlight = {
	--	keyword = "wide_bg"
	--}
})
