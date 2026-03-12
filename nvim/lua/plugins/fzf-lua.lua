-- ============================================================================
-- FZF-LUA — fuzzy finder con ripgrep
-- ============================================================================
require("fzf-lua").setup({
	"default",
	fzf_colors = true,
	defaults = {
		file_icons = "devicons",
	},
	fzf_opts = {
		["--layout"] = "reverse",
	},
	files = {
		cmd = "rg --files --follow --no-ignore-vcs --hidden "
			.. "-g '!.git' "
			.. "-g '!node_modules' "
			.. "-g '!dist' "
			.. "-g '!build' "
			.. "-g '!.next' "
			.. "-g '!vendor' "
			.. "-g '!design' "
			.. "-g '!pnpm-lock.yaml' "
			.. "-g '!package-lock.json'",
	},
	grep = {
		cmd = "rg --column --line-number --no-heading --color=always --smart-case "
			.. "-g '!.git' "
			.. "-g '!node_modules' "
			.. "-g '!dist' "
			.. "-g '!build' "
			.. "-g '!.next' "
			.. "-g '!vendor' "
			.. "-g '!design' "
			.. "-g '!pnpm-lock.yaml' "
			.. "-g '!package-lock.json'",
	},
})

vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end,                 { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end,             { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end,               { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function() require("fzf-lua").help_tags() end,             { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function() require("fzf-lua").diagnostics_document() end,  { desc = "FZF Diagnostics Doc" })
vim.keymap.set("n", "<leader>fX", function() require("fzf-lua").diagnostics_workspace() end, { desc = "FZF Diagnostics WS" })
vim.keymap.set("n", "<leader>fr", function() require("fzf-lua").resume() end,                { desc = "FZF Resume last" })
