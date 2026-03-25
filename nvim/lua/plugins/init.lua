-- ============================================================================
-- PLUGINS — instalación con vim.pack y carga de configs
-- ============================================================================
vim.pack.add({
	"https://github.com/airblade/vim-gitgutter",
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/nvim-tree/nvim-web-devicons",
	{
		src    = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build  = ":TSUpdate",
	},
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src     = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/tomasiser/vim-code-dark",
	"https://github.com/christoomey/vim-tmux-navigator",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("vim-code-dark")
packadd("nvim-treesitter")
packadd("vim-gitgutter")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("nvim-web-devicons")
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")
packadd("vim-fugitive")
packadd("vim-tmux-navigator")

vim.cmd.colorscheme("codedark")

-- Configs de cada plugin
require("plugins.treesitter")
require("plugins.nvim-tree")
require("plugins.fzf-lua")
require("plugins.mini")
require("plugins.gitgutter")
require("plugins.lsp")
require("plugins.terminal")
require("plugins.vim-tmux-navigator")
