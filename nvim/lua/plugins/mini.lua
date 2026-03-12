-- ============================================================================
-- MINI.NVIM — colección de micro-plugins
-- ============================================================================
require("mini.ai").setup({})          -- mejores text objects (ci", ca{, etc)
require("mini.comment").setup({})     -- gc para comentar
require("mini.move").setup({})        -- Alt+hjkl para mover lineas/selección
require("mini.surround").setup({})    -- sa, sd, sr para surround
require("mini.cursorword").setup({})  -- resalta la palabra bajo el cursor
require("mini.indentscope").setup({}) -- muestra el scope de indentación
require("mini.pairs").setup({})       -- cierra paréntesis/comillas
require("mini.trailspace").setup({})  -- marca espacios en blanco al final
require("mini.bufremove").setup({})   -- borra buffers sin cerrar ventana
require("mini.notify").setup({})      -- notificaciones flotantes
