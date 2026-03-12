-- ============================================================================
-- LSP, LINTING & FORMATTING — solo web dev
-- ============================================================================

-- Mason — gestor de instalación de LSPs/linters/formatters
-- Instala con: :MasonInstall typescript-language-server eslint_d prettier_d-slim
--              json-lsp bash-language-server lua-language-server
require("mason").setup({})

-- Signos de diagnóstico
local diagnostic_signs = {
	Error = " ",
	Warn  = " ",
	Hint  = "",
	Info  = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN]  = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO]  = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT]  = diagnostic_signs.Hint,
		},
	},
	underline        = true,
	update_in_insert = false,
	severity_sort    = true,
	float = {
		border    = "rounded",
		source    = "always",
		header    = "",
		prefix    = "",
		focusable = false,
		style     = "minimal",
	},
})

-- Bordes redondeados en floating windows del LSP
do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts        = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

-- Keymaps LSP (se activan solo cuando un LSP se conecta al buffer)
local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then return end

	local bufnr = ev.buf
	local opts  = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      opts)
	vim.keymap.set("n", "K",          vim.lsp.buf.hover,        opts)

	vim.keymap.set("n", "<leader>D",  function() vim.diagnostic.open_float({ scope = "line" })   end, opts)
	vim.keymap.set("n", "<leader>d",  function() vim.diagnostic.open_float({ scope = "cursor" }) end, opts)
	vim.keymap.set("n", "<leader>nd", function() vim.diagnostic.jump({ count = 1 })              end, opts)
	vim.keymap.set("n", "<leader>pd", function() vim.diagnostic.jump({ count = -1 })             end, opts)

	-- FZF + LSP
	vim.keymap.set("n", "<leader>fd", function() require("fzf-lua").lsp_definitions({ jump_to_single_result = true }) end, opts)
	vim.keymap.set("n", "<leader>fR", function() require("fzf-lua").lsp_references() end,        opts)
	vim.keymap.set("n", "<leader>ft", function() require("fzf-lua").lsp_typedefs() end,           opts)
	vim.keymap.set("n", "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end,  opts)
	vim.keymap.set("n", "<leader>fw", function() require("fzf-lua").lsp_workspace_symbols() end, opts)
	vim.keymap.set("n", "<leader>fi", function() require("fzf-lua").lsp_implementations() end,   opts)

	-- Organizar imports + format al guardar
	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply   = true,
				bufnr   = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = _G.user_augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- ============================================================================
-- BLINK.CMP — autocompletado
-- ============================================================================
require("blink.cmp").setup({
	keymap = {
		preset        = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"]      = { "accept", "fallback" },
		["<C-j>"]     = { "select_next", "fallback" },
		["<C-k>"]     = { "select_prev", "fallback" },
		["<Tab>"]     = { "snippet_forward", "fallback" },
		["<S-Tab>"]   = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources    = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = {
		implementation    = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

-- ============================================================================
-- LSP SERVERS — solo web dev
-- ============================================================================
vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

-- TypeScript / JavaScript (React, Next, Node, Nest)
vim.lsp.config("ts_ls", {})

-- JSON con schemas
vim.lsp.config("jsonls", {
	settings = {
		json = {
			validate = { enable = true },
		},
	},
})

-- Bash
vim.lsp.config("bashls", {})

-- Lua (para editar este init.lua)
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry   = { enable = false },
		},
	},
})

vim.lsp.enable({
	"ts_ls",
	"jsonls",
	"bashls",
	"lua_ls",
	"efm",
})

-- ============================================================================
-- EFM — linting y formatting para web dev
-- ============================================================================
do
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d   = require("efmls-configs.linters.eslint_d")
	local fixjson    = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt      = require("efmls-configs.formatters.shfmt")
	local stylua     = require("efmls-configs.formatters.stylua")

	vim.lsp.config("efm", {
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"json",
			"css",
			"scss",
			"html",
			"markdown",
			"vue",
			"svelte",
			"sh",
			"bash",
			"lua",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				javascript      = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				typescript      = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				json            = { eslint_d, fixjson },
				css             = { prettier_d },
				scss            = { prettier_d },
				html            = { prettier_d },
				markdown        = { prettier_d },
				vue             = { eslint_d, prettier_d },
				svelte          = { eslint_d, prettier_d },
				sh              = { shellcheck, shfmt },
				bash            = { shellcheck, shfmt },
				lua             = { stylua },
			},
		},
	})
end
