-- ============================================================================
-- AUTOCMDS
-- ============================================================================

-- augroup global para que plugins/lsp.lua pueda referenciarlo
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })
_G.user_augroup = augroup

-- Format on save (solo web dev + shell)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.js", "*.jsx",
		"*.ts", "*.tsx",
		"*.json",
		"*.css", "*.scss",
		"*.html",
		"*.vue", "*.svelte",
		"*.md",
		"*.sh", "*.bash", "*.zsh",
		"*.lua",
	},
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then return end
		if not vim.bo[args.buf].modifiable then return end
		if vim.api.nvim_buf_get_name(args.buf) == "" then return end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then return end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c) return c.name == "efm" end,
		})
	end,
})

-- Pint (Laravel) — corre DESPUÉS de guardar, sobre el archivo real en disco,
-- y recarga el buffer. Pint no soporta stdin: formatea el archivo in-place.
-- Si corriera en BufWritePre (antes de escribir), formatearía la versión
-- vieja que todavía está en disco y el resultado pisaría el cambio recién
-- hecho por el usuario al guardar.
vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup,
	pattern = "*.php",
	callback = function(args)
		local root = vim.fs.root(args.file, "composer.json") or vim.fn.getcwd()
		local pint = root .. "/vendor/bin/pint"
		if vim.fn.executable(pint) == 0 then
			pint = "pint"
			if vim.fn.executable(pint) == 0 then return end
		end

		vim.system({ pint, args.file }, { text = true }, function()
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(args.buf) then
					vim.api.nvim_buf_call(args.buf, function()
						vim.cmd("checktime")
					end)
				end
			end)
		end)
	end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function() vim.hl.on_yank() end,
})

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then return end
		local last_pos  = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = vim.api.nvim_buf_line_count(0)
		local row = last_pos[1]
		if row < 1 or row > last_line then return end
		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- Wrap + spell en markdown
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap      = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell     = true
	end,
})
