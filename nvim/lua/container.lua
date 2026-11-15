-- ============================================================================
-- CONTAINER — ruta a ~/dotfiles/bin/container-exec
-- Ejecuta comandos (php, composer, pint…) en el contenedor que monta el
-- proyecto. El host no tiene PHP: todo corre en contenedores.
-- Exit code 3 = no hay contenedor corriendo para ese proyecto.
-- ============================================================================
local M = {}

-- stdpath("config") es un symlink a ~/dotfiles/nvim → bin/ está al lado
M.exec = vim.fs.normalize(vim.fn.resolve(vim.fn.stdpath("config")) .. "/../bin/container-exec")

M.NOT_RUNNING = 3

return M
