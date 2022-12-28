local which_key = require("which-key")

which_key.register({
    ["<leader>c"] = {
        name = "+commands",
        s = { "<cmd>lua require'plugins.telescope'.command_finder()<cr>", "Commands" },
        h = { "<cmd>lua require'plugins.telescope'.command_history_finder()<cr>", "Command History" },
    },
    ["<leader>e"] = {
        name = "+emojis",
        s = { "<cmd>Telescope symbols<cr>", "Emojis" },
    },
    ["<leader>f"] = {
        name = "+file",
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        o = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
        b = { "<cmd>Telescope buffers<cr>", "Search Files in Buffers" },
    },
    ["<leader>l"] = {
        name = "+lsp",
        r = { "<cmd>Telescope lsp_references<cr>", "LSP References" },
        i = { "<cmd>Telescope lsp_implementations<cr>", "LSP Implementations" },
        d = { "<cmd>Telescope lsp_document_symbols<cr>", "LSP Document Symbols" },
        t = { "<cmd>Telescope lsp_type_definitions<cr>", "LSP Type Definitions" },
        w = { "<cmd>Telescope lsp_workspace_symbols<cr>", "LSP Workspace Symbols" },
        x = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "LSP Dynamic Workspace Symbols" },
    },
    ["<leader>g"] = {
        name = "+git",
        c = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
        b = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
        B = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Git Blame" },
        s = { "<cmd>Telescope git_status<cr>", "Git Status" },
    },
    ["<leader>r"] = {
        name = "+repl",
        t = { "<cmd>IronRepl<cr>", "Toggle repl" },
        r = { "<cmd>IronRestart<cr>", "Restart repl" },
        f = { "<cmd>IronFocus<cr>", "Focus repl" },
        h = { "<cmd>IronHide<cr>", "Hide repl" },
    },
    ["<leader>s"] = {
        name = "+search",
        s = { "<cmd>Telescope grep_string<cr>", "Grep Under Cursor" },
        g = { "<cmd>Telescope live_grep<cr>", "Grep Search" },
        h = { "<cmd>Telescope help_tags<cr>", "Search Help Tags" },
    },
    ["<leader>t"] = {
        -- NOTE: load keybinds in gtd config to override g since git wont be used in gtd
        name = "+tree",
        t = { "<cmd>NvimTreeToggle<cr>", "Open/Close nvim-tree" },
        f = { "<cmd>NvimTreeFocus<cr>", "Open and Focus on nvim-tree" },
        F = { "<cmd>NvimTreeFindFile<cr>", "Open nvim-tree to Current File" },
        --	e = { "<cmd>Neorg gtd edit<cr>", "Neorg Task Edit" },
        --	c = { "<cmd>Neorg gtd capture<cr>", "Neorg Task Capture" },
        --	v = { "<cmd>Neorg gtd views<cr>", "Neorg Task Views" },
    },
    ["<leader>p"] = {
        name = "+packer",
        c = { "<cmd>PackerClean<cr>", "Packer Clean" },
        C = { "<cmd>PackerCompile<cr>", "Packer Compile" },
        i = { "<cmd>PackerInstall<cr>", "Packer Install" },
        u = { "<cmd>PackerUpdate<cr>", "Packer Update" },
        s = { "<cmd>PackerSync<cr>", "Packer Sync" },
        l = { "<cmd>PackerLoad<cr>", "Packer Load" },
    },
    ["<leader>w"] = { "<cmd>update!<cr>", "Save" },
    ["<leader>z"] = { "<cmd>ZenMode<cr>", "Zen Mode" },
})

which_key.register({
    ["<C-k>"] = { "<cmd>wincmd k<cr>", "Up" },
    ["<C-j>"] = { "<cmd>wincmd j<cr>", "Down" },
    ["<C-h>"] = { "<cmd>wincmd h<cr>", "Left" },
    ["<C-l>"] = { "<cmd>wincmd l<cr>", "Right" },
    ["<C-x>"] = { "<cmd>lua reload_nvim_conf()<cr>", "Reload Configs" },
})

which_key.setup({
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "→", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    disable = {
        buftypes = {},
        filetypes = {
            "TelescopePrompt",
            "norg",
            "neorg",
        },
    },
})
