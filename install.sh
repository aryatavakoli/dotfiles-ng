#!/usr/bin/env bash
# Dotfiles installer for macOS and Linux
set -e

# ============================================================
# Configuration
# ============================================================
# Leave empty to prompt during installation
USER_NAME="${USER_NAME:-}"
USER_EMAIL="${USER_EMAIL:-}"

# ============================================================
# Colors & Logging
# ============================================================
C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'; C_NC='\033[0m'

info() { echo -e "${C_GREEN}▸${C_NC} $1"; }
warn() { echo -e "${C_YELLOW}⚠${C_NC} $1"; }
error() { echo -e "${C_RED}✗${C_NC} $1"; exit 1; }

banner() {
    echo -e "${C_BLUE}"
    echo "┌────────────────────────────────────┐"
    echo "│   Dotfiles Installation (Chezmoi)  │"
    echo "└────────────────────────────────────┘"
    echo -e "${C_NC}"
}

# ============================================================
# OS Detection
# ============================================================
is_mac() { [[ "$OSTYPE" == "darwin"* ]]; }
is_linux() { [[ "$OSTYPE" == "linux"* ]]; }
is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

detect_os() {
    if is_mac; then
        echo "macos"
    elif is_wsl; then
        echo "wsl"
    elif is_linux; then
        echo "linux"
    else
        error "Unsupported OS: $OSTYPE"
    fi
}

# ============================================================
# Install chezmoi
# ============================================================
install_chezmoi() {
    command -v chezmoi &>/dev/null && return 0
    
    info "Installing chezmoi..."
    if is_mac && command -v brew &>/dev/null; then
        brew install chezmoi
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# ============================================================
# Configure chezmoi
# ============================================================
configure_chezmoi() {
    # Skip if config already exists
    if [[ -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
        info "Using existing chezmoi config"
        return 0
    fi
    
    # Get user info (prompt if not set)
    local user_name="${USER_NAME}"
    local user_email="${USER_EMAIL}"
    
    if [[ -z "$user_name" ]]; then
        echo
        read -p "Name: " user_name
    fi
    
    if [[ -z "$user_email" ]]; then
        read -p "Email: " user_email
        echo
    fi
    
    # Create config
    mkdir -p "$HOME/.config/chezmoi"
    cat > "$HOME/.config/chezmoi/chezmoi.toml" <<EOF
[data]
    name = "$user_name"
    email = "$user_email"
EOF
    info "Config created at ~/.config/chezmoi/chezmoi.toml"
}

# ============================================================
# Copy dotfiles
# ============================================================
copy_dotfiles() {
    local src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dest="$HOME/.local/share/chezmoi"
    
    info "Copying dotfiles to $dest..."
    
    # Create destination directory
    mkdir -p "$dest"
    
    # Copy files (chezmoi will handle exclusions via .chezmoiignore)
    cp -r "$src/." "$dest/"
    
    # Make scripts executable
    find "$dest/.chezmoiscripts" -name "*.tmpl" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    info "✓ Dotfiles copied"
    
    # Regenerate config from template to avoid warnings
    info "Regenerating config from template..."
    chezmoi init --force
    info "✓ Config regenerated"
}

# ============================================================
# Preview & Apply
# ============================================================
apply_dotfiles() {
    echo
    info "Reviewing changes..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    chezmoi diff
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    read -p "Apply changes? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warn "Skipped. Run 'chezmoi apply -v' later."
        exit 0
    fi
    
    chezmoi apply -v
    info "✓ Dotfiles applied"
}

# ============================================================
# Setup shell
# ============================================================
setup_shell() {
    # Skip if already using zsh
    [[ "$SHELL" =~ zsh ]] && return 0
    
    # Check if zsh is installed
    if ! command -v zsh &>/dev/null; then
        warn "zsh not installed. Install it using your package manager."
        return 1
    fi
    
    info "Changing default shell to zsh..."
    local zsh_path="$(command -v zsh)"
    
    if is_mac; then
        chsh -s "$zsh_path"
    else
        # Add to /etc/shells if needed
        if ! grep -qxF "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        sudo chsh -s "$zsh_path" "$USER"
    fi
    
    warn "Log out and back in for shell change to take effect"
}

# ============================================================
# Main
# ============================================================
main() {
    local os=$(detect_os)
    
    banner
    info "Detected OS: $os"
    echo
    
    install_chezmoi
    configure_chezmoi
    copy_dotfiles
    apply_dotfiles
    setup_shell
    
    echo
    echo -e "${C_GREEN}✓ Setup complete!${C_NC}"
    echo
    info "Next steps:"
    info "  1. exec zsh (or restart terminal)"
    info "  2. Packages will sync on first startup"
    echo
}

main "$@"
