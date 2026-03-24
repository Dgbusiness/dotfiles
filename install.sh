#!/usr/bin/env bash
# =============================================================================
# install.sh — dotfiles setup for WSL2 + Ubuntu
# Installs: Neovim nightly, dependencies (fzf, ripgrep, bat, zoxide, starship,
#           tmux), JetBrainsMono Nerd Font, creates symlinks and configures .bashrc
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

log()     { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "${RED}[✘]${RESET} $1"; exit 1; }
section() { echo -e "\n${BOLD}──────────────────────────────────────${RESET}"; echo -e "${BOLD} $1${RESET}"; echo -e "${BOLD}──────────────────────────────────────${RESET}"; }

confirm() {
  read -rp "$1 [y/N] " ans
  [[ "$ans" =~ ^[yY]$ ]]
}

# =============================================================================
# 0. Pre-checks
# =============================================================================
section "Checking environment"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  warn "WSL2 not detected — continuing anyway..."
fi

if ! command -v apt &>/dev/null; then
  error "This script requires apt (Ubuntu/Debian)"
fi

log "Installing base requirements (sudo, curl, fontconfig)..."
apt install -y sudo curl fontconfig

log "Updating package list..."
sudo apt update -qq 

# =============================================================================
# 1. Neovim nightly
# =============================================================================
section "Neovim (nightly)"

NVIM_TAR="nvim-linux-x86_64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/${NVIM_TAR}"
NVIM_DEST="/opt/nvim-linux-x86_64"

if command -v nvim &>/dev/null; then
  CURRENT_NVIM=$(nvim --version | head -1)
  warn "Neovim already installed: ${CURRENT_NVIM}"
  if confirm "Reinstall Neovim nightly?"; then
    sudo rm -rf "$NVIM_DEST"
  else
    log "Skipping Neovim installation"
  fi
fi

if ! command -v nvim &>/dev/null || [ ! -d "$NVIM_DEST" ]; then
  log "Downloading Neovim nightly..."
  curl -fsSL "$NVIM_URL" -o "/tmp/${NVIM_TAR}"
  sudo rm -rf "$NVIM_DEST"
  sudo tar -xzf "/tmp/${NVIM_TAR}" -C /opt
  rm -f "/tmp/${NVIM_TAR}"
  log "Neovim installed at ${NVIM_DEST}"
fi

# =============================================================================
# 2. Base dependencies
# =============================================================================
section "Dependencies (fzf, ripgrep, bat, tmux, curl, git, unzip)"

PKGS=(fzf ripgrep bat tmux curl git unzip build-essential)
MISSING=()

for pkg in "${PKGS[@]}"; do
  if ! dpkg -l "$pkg" &>/dev/null; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  log "Installing: ${MISSING[*]}"
  sudo apt install -y "${MISSING[@]}"
else
  log "All packages already installed"
fi

# =============================================================================
# 3. Zoxide
# =============================================================================
section "Zoxide"

if command -v zoxide &>/dev/null; then
  log "Zoxide already installed: $(zoxide --version)"
else
  log "Installing zoxide..."
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  log "Zoxide installed"
fi

# =============================================================================
# 4. Starship
# =============================================================================
section "Starship"

if command -v starship &>/dev/null; then
  log "Starship already installed: $(starship --version | head -1)"
else
  log "Installing starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  log "Starship installed"
fi

# =============================================================================
# 5. JetBrainsMono Nerd Font
# =============================================================================
section "JetBrainsMono Nerd Font"

FONT_DIR="$HOME/.local/share/fonts"
FONT_CHECK="${FONT_DIR}/JetBrainsMonoNerdFont-Regular.ttf"

if [ -f "$FONT_CHECK" ]; then
  log "JetBrainsMono Nerd Font already installed"
else
  log "Downloading JetBrainsMono Nerd Font..."
  FONT_VERSION="v3.3.0"
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
  mkdir -p "$FONT_DIR"
  curl -fsSL "$FONT_URL" -o "/tmp/JetBrainsMono.zip"
  unzip -o -q "/tmp/JetBrainsMono.zip" "*.ttf" -d "$FONT_DIR"
  rm -f "/tmp/JetBrainsMono.zip"
  fc-cache -f "$FONT_DIR"
  log "JetBrainsMono Nerd Font installed at ${FONT_DIR}"
  warn "Remember to set the font in Windows Terminal: JetBrainsMono Nerd Font Mono"
fi

# =============================================================================
# 6. Dotfile symlinks
# =============================================================================
section "Creating symlinks"

symlink() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  mkdir -p "$dest_dir"

  if [ -L "$dest" ]; then
    rm "$dest"
    log "Replaced existing symlink: ${dest}"
  elif [ -e "$dest" ]; then
    local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$dest" "$backup"
    warn "Existing file backed up: ${backup}"
  fi

  ln -s "$src" "$dest"
  log "Symlink: ${dest} → ${src}"
}

# Neovim
symlink "${DOTFILES_DIR}/nvim"                   "$HOME/.config/nvim"

# Tmux
symlink "${DOTFILES_DIR}/tmux/tmux.conf"         "$HOME/.tmux.conf"

# Starship
symlink "${DOTFILES_DIR}/starship/starship.toml" "$HOME/.config/starship.toml"

# =============================================================================
# 7. .bashrc
# =============================================================================
section "Configuring .bashrc"

BASHRC="$HOME/.bashrc"
MARKER="# === dotfiles additions ==="

if grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
  log ".bashrc already has dotfiles additions (skipping)"
else
  log "Appending additions to .bashrc..."
  cat >> "$BASHRC" << 'EOF'

# === dotfiles additions ===

# Neovim (installed at /opt)
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Starship prompt
eval "$(starship init bash)"

# Zoxide (replaces cd)
export PATH="$PATH:$HOME/.local/bin"
eval "$(zoxide init bash)"

EOF
  log ".bashrc updated"
fi

# =============================================================================
# 8. LSPs via Mason (headless Neovim)
# =============================================================================
section "Installing LSPs via Mason"

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

if ! command -v nvim &>/dev/null; then
  warn "Neovim not found in PATH, skipping LSP installation"
else
  log "Installing: typescript-language-server, json-lsp, bash-language-server, lua-language-server, eslint_d, prettier_d-slim, efm-langserver..."
  nvim --headless \
    +"MasonInstall typescript-language-server json-lsp bash-language-server lua-language-server eslint_d prettier_d-slim efm-langserver" \
    +qa 2>/dev/null || warn "LSPs installed (warnings in headless mode are normal)"
  log "LSPs installed"
fi

# =============================================================================
# Summary
# =============================================================================
section "✅ Installation complete"

echo ""
echo -e "  ${BOLD}Dotfiles:${RESET}  ${DOTFILES_DIR}"
echo -e "  ${BOLD}Neovim:${RESET}    ~/.config/nvim          → ${DOTFILES_DIR}/nvim"
echo -e "  ${BOLD}Tmux:${RESET}      ~/.tmux.conf            → ${DOTFILES_DIR}/tmux/tmux.conf"
echo -e "  ${BOLD}Starship:${RESET}  ~/.config/starship.toml → ${DOTFILES_DIR}/starship/starship.toml"
echo ""
echo -e "  ${YELLOW}Next steps:${RESET}"
echo -e "  1. Reload shell:           ${BOLD}source ~/.bashrc${RESET}"
echo -e "  2. Open Neovim to sync plugins: ${BOLD}nvim${RESET}"
echo -e "  3. Set font in Windows Terminal: ${BOLD}JetBrainsMono Nerd Font Mono${RESET}"
echo ""
