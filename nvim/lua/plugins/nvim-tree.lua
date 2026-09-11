-- ============================================================================
-- NVIM-TREE — explorador de archivos
-- ============================================================================
local api = require("nvim-tree.api")

local function on_attach(bufnr)
	api.config.mappings.default_on_attach(bufnr)

	local opts = function(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close directory"))
	vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
end

require("nvim-tree").setup({
	on_attach = on_attach,
	view    = { width = 35 },
	filters = { dotfiles = false },
	git     = { enable = true, ignore = false },
	update_focused_file = { enable = true },
	renderer = {
		group_empty   = true,
		highlight_git = true,
		icons = {
			show = { git = true },
		},
	},
})

vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

vim.api.nvim_set_hl(0, "NvimTreeNormalNC",    { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn",           { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn",   { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal",       { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer",  { bg = "none" })
