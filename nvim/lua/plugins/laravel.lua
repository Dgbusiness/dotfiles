-- ============================================================================
-- LARAVEL.NVIM
-- ============================================================================
-- Entorno "container": php/composer/npm/artisan corren dentro del contenedor
-- que monta el proyecto (vía container-exec), sin importar cómo se llame el
-- servicio (api.adgem, app, servicehub.adgem…). El host no tiene PHP.
local exec = require("container").exec

require("laravel").setup({
	features = {
		pickers = {
			provider = "fzf-lua",
		},
	},
	environments = {
		default = "container",
		definitions = {
			{
				name = "container",
				map = {
					php = { exec, "php" },
					composer = { exec, "composer" },
					npm = { exec, "npm" },
					yarn = { exec, "yarn" },
				},
			},
		},
	},
})
