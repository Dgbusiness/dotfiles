-- ============================================================================
-- VIM-TMUX-NAVIGATOR — navegación seamless entre splits de nvim y panes de tmux
-- ============================================================================
vim.g.tmux_navigator_no_mappings = 1

vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  { silent = true, desc = "Navigate left (nvim/tmux)" })
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<CR>",  { silent = true, desc = "Navigate down (nvim/tmux)" })
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<CR>",    { silent = true, desc = "Navigate up (nvim/tmux)" })
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true, desc = "Navigate right (nvim/tmux)" })
