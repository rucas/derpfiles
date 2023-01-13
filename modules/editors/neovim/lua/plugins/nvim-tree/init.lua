local nvim_tree = require("nvim-tree")
local lib = require("nvim-tree.lib")
local view = require("nvim-tree.view")

local function collapse_all()
	require("nvim-tree.actions.collapse-all").fn()
end

local function edit_or_open()
	-- open as vsplit on current node
	local action = "edit"
	local node = lib.get_node_at_cursor()

	-- Just copy what's done normally with vsplit
	if node.link_to and not node.nodes then
		require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
		view.close() -- Close the tree if file was opened
	elseif node.nodes ~= nil then
		lib.expand_or_collapse(node)
	else
		require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
		view.close() -- Close the tree if file was opened
	end
end

local function vsplit_preview()
	-- open as vsplit on current node
	local action = "vsplit"
	local node = lib.get_node_at_cursor()

	-- Just copy what's done normally with vsplit
	if node.link_to and not node.nodes then
		require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
	elseif node.nodes ~= nil then
		lib.expand_or_collapse(node)
	else
		require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
	end

	-- Finally refocus on tree if it was lost
	view.focus()
end

nvim_tree.setup({
	--sync_root_with_cwd = true,
	--respect_buf_cwd = true,
	update_focused_file = {
		enable = true,
		update_root = true,
	},
	view = {
		adaptive_size = true,
		cursorline = false,
		hide_root_folder = false,
		mappings = {
			custom_only = false,
			list = {
				{ key = "l", action = "edit", action_cb = edit_or_open },
				{ key = "L", action = "vsplit_preview", action_cb = vsplit_preview },
				{ key = "h", action = "close_node" },
				{ key = "H", action = "collapse_all", action_cb = collapse_all },
			},
		},
	},
	actions = {
		open_file = {
			quit_on_open = false,
		},
	},
	renderer = {
		root_folder_label = function(_)
			return ""
		end,
		indent_width = 2,
		icons = {
			padding = " ",
			show = {
				git = false,
			},
		},
	},
	filters = {
		custom = {
			"^.git$",
		},
	},
})
