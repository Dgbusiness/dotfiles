-- ============================================================================
-- VIM-GITGUTTER — indicadores de git en el gutter
-- ============================================================================
vim.g.gitgutter_sign_added              = "▐"
vim.g.gitgutter_sign_modified           = "▐"
vim.g.gitgutter_sign_removed            = "▐"
vim.g.gitgutter_sign_removed_first_line = "◦"
vim.g.gitgutter_sign_modified_removed   = "●"

vim.keymap.set("n", "]h",         "<Plug>(GitGutterNextHunk)",    { desc = "Next git hunk" })
vim.keymap.set("n", "[h",         "<Plug>(GitGutterPrevHunk)",    { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", "<Plug>(GitGutterStageHunk)",   { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", "<Plug>(GitGutterRevertHunk)",  { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", "<Plug>(GitGutterPreviewHunk)", { desc = "Preview hunk" })
