-- ============================================================================
-- MASON INSTALL — fuente única de paquetes LSP/linters/formatters
-- Uso: nvim --headless "+luafile ~/dotfiles/scripts/mason-install.lua"
-- (`:MasonInstall` + `+qa` en headless sale antes de terminar de instalar)
-- ============================================================================
local packages = {
	-- JS / TS / React / Vue
	"typescript-language-server",
	"vue-language-server",
	"eslint_d",
	"prettierd",
	-- PHP / Laravel / Livewire / Filament (Blade)
	"intelephense",
	"blade-formatter",
	-- JSON
	"json-lsp",
	"fixjson",
	-- Shell (install.sh, scripts)
	"bash-language-server",
	"shellcheck",
	"shfmt",
	-- Lua (config de nvim)
	"lua-language-server",
	"stylua",
	-- Linting/formatting server
	"efm",
}

local registry = require("mason-registry")
local pending, failed = 0, 0

registry.refresh(function(ok, err)
	if not ok then
		io.stderr:write("mason: registry refresh failed: " .. tostring(err) .. "\n")
		vim.cmd("cq")
	end
	for _, name in ipairs(packages) do
		local found, pkg = pcall(registry.get_package, name)
		if not found then
			failed = failed + 1
			print("NOT FOUND: " .. name)
		elseif not pkg:is_installed() then
			pending = pending + 1
			pkg:install({}, function(success, result)
				if not success then failed = failed + 1 end
				print((success and "OK: " or "FAIL: ") .. name .. (success and "" or (" -> " .. tostring(result))))
				pending = pending - 1
			end)
		end
	end
end)

-- Espera a que el refresh dispare las instalaciones y a que terminen (máx 10 min)
vim.wait(2000)
vim.wait(600000, function() return pending == 0 end, 500)
print(string.format("mason: done (%d failed)", failed))
vim.cmd(failed > 0 and "cq" or "qa!")
