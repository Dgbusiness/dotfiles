# =============================================================================
# .bashrc additions — pegá esto al final de tu ~/.bashrc
# (el install.sh lo hace automáticamente)
# =============================================================================

# Neovim (instalado en /opt)
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Starship prompt
eval "$(starship init bash)"

# Zoxide (reemplaza cd)
export PATH="$PATH:$HOME/.local/bin"
eval "$(zoxide init bash)"

# Tmux — arrancar automáticamente si no hay sesión activa
if [ -z "$TMUX" ]; then
  tmux attach 2>/dev/null || tmux new-session
fi
