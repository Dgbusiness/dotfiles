-- ============================================================================
-- AUTOCMDS
-- ============================================================================

-- augroup global para que plugins/lsp.lua pueda referenciarlo
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })
_G.user_augroup = augroup

-- Por defecto nvim detecta *.blade.php como filetype "php" (matchea la
-- última extensión). Lo pasamos a "blade" para que efm use blade-formatter
-- en vez de tratarlo como PHP puro (blade mezcla HTML + directivas + PHP).
vim.filetype.add({
	pattern = {
		[".*%.blade%.php"] = "blade",
	},
})

-- Format on save (solo web dev + shell)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.js", "*.jsx",
		"*.ts", "*.tsx",
		"*.json",
		"*.css", "*.scss",
		"*.html",
		"*.vue",
		"*.md",
		"*.sh", "*.bash", "*.zsh",
		"*.lua",
		"*.blade.php",
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
--
-- Corre DENTRO del contenedor del proyecto (container-exec): el host no
-- tiene PHP. Si el contenedor está apagado, se omite y avisa una vez.
local container = require("container")
local pint_warned = {}

vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup,
	pattern = "*.php",
	callback = function(args)
		-- Pint solo entiende PHP puro; los .blade.php los formatea
		-- blade-formatter (vía efm, filetype "blade").
		if args.file:match("%.blade%.php$") then return end

		local file = vim.fs.normalize(vim.fn.fnamemodify(args.file, ":p"))
		local root = vim.fs.root(file, "composer.json")
		if not root then return end
		-- vendor/ está en el host por el bind mount; sin pint, el proyecto no lo usa
		if vim.fn.filereadable(root .. "/vendor/bin/pint") == 0 then return end

		local rel = vim.fs.relpath(root, file)
		vim.system({ container.exec, "vendor/bin/pint", rel }, { cwd = root, text = true }, function(res)
			vim.schedule(function()
				if res.code == container.NOT_RUNNING then
					if not pint_warned[root] then
						pint_warned[root] = true
						vim.notify("Pint omitido: el contenedor de " .. vim.fs.basename(root) .. " está apagado",
							vim.log.levels.WARN)
					end
					return
				end
				pint_warned[root] = nil
				if res.code ~= 0 then
					vim.notify("Pint falló:\n" .. vim.trim((res.stderr or "") .. (res.stdout or "")), vim.log.levels.ERROR)
					return
				end
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
