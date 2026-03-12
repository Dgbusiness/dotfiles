-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- Search
vim.keymap.set("n", "<leader>c",  ":nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>s",  "/",               { desc = "Search in file" })
vim.keymap.set("n", "n",          "nzzzv",            { desc = "Next search result (centered)" })
vim.keymap.set("n", "N",          "Nzzzv",            { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>",      "<C-d>zz",          { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>",      "<C-u>zz",          { desc = "Half page up (centered)" })

-- Editing
vim.keymap.set("x",          "<leader>p", '"_dP',  { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d',   { desc = "Delete without yanking" })
vim.keymap.set("n",          "J",         "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==",       { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==",       { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv",  { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv",  { desc = "Move selection up" })

-- Indent and reselect
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Buffers
vim.keymap.set("n", "<leader>bn", ":bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window splits and resize
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>",            { desc = "Split vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>",             { desc = "Split horizontally" })
vim.keymap.set("n", "<C-Up>",    ":resize +2<CR>",          { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>",  ":resize -2<CR>",          { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>",  ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- File
vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

-- Save / quit (sin sobreescribir w/q nativos)
vim.keymap.set("n", "<leader>w",  ":w<CR>",  { desc = "Save file" })
vim.keymap.set("n", "<leader>q",  ":q<CR>",  { desc = "Close" })
vim.keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and exit" })

-- Diagnostics toggle
vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ============================================================================
-- GIT — vim-fugitive
-- ============================================================================
vim.keymap.set("n", "<leader>gs",  ":Git<CR>",               { desc = "Git status" })
vim.keymap.set("n", "<leader>ga",  ":Git add %<CR>",         { desc = "Git add file" })
vim.keymap.set("n", "<leader>gc",  ":Git commit<CR>",        { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp",  ":Git push<CR>",          { desc = "Git push" })
vim.keymap.set("n", "<leader>gl",  ":Git pull<CR>",          { desc = "Git pull" })
vim.keymap.set("n", "<leader>gb",  ":Git blame<CR>",         { desc = "Git blame" })
vim.keymap.set("n", "<leader>gL",  ":Git log --oneline<CR>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gd",  ":Gvdiffsplit<CR>",       { desc = "Git diff split" })
vim.keymap.set("n", "<leader>gco", ":Git checkout ",         { desc = "Git checkout" })

-- ============================================================================
-- TERMINALES SPLIT (persistentes)
-- ============================================================================
local split_terms = { h = { buf = nil }, v = { buf = nil } }

local function open_split_terminal(direction)
	local state = split_terms[direction]

	-- Abrir el split con el tamaño correcto
	if direction == "h" then
		vim.cmd("split")
		vim.cmd("resize " .. math.floor(vim.o.lines * 0.3))
	else
		vim.cmd("vsplit")
		vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.4))
	end

	-- Si el buffer existe y es válido, reutilizarlo
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_win_set_buf(0, state.buf)
	else
		-- Crear buffer nuevo con terminal
		vim.cmd("terminal")
		state.buf = vim.api.nvim_get_current_buf()
		vim.bo[state.buf].bufhidden = "hide"
	end

	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>th", function()
	open_split_terminal("h")
end, { desc = "Terminal abajo (persistente)" })

vim.keymap.set("n", "<leader>tv", function()
	open_split_terminal("v")
end, { desc = "Terminal derecha (persistente)" })

-- Cerrar terminal desde modo terminal con Ctrl+q
-- Cierra la ventana pero mantiene el buffer vivo
vim.keymap.set("t", "<C-q>", "<C-\\><C-n><C-w>c", { desc = "Cerrar ventana terminal (mantiene buffer)" })

-- Navegación desde modo terminal
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal → izquierda" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal → abajo" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal → arriba" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal → derecha" })
