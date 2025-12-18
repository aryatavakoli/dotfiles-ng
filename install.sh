#!/usr/bin/env bash
# Dotfiles installer for macOS, Linux, and WSL (SAFE VERSION)
set -euo pipefail

# ============================================================
# Guards
# ============================================================
if [[ "$(id -u)" -eq 0 ]]; then
    echo "✗ Do not run this script as root"
    exit 1
fi

# ============================================================
# Configuration
# ============================================================
USER_NAME="${USER_NAME:-}"
USER_EMAIL="${USER_EMAIL:-}"

# ============================================================
# Colors & Logging
# ============================================================
C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'; C_NC='\033[0m'

info()  { echo -e "${C_GREEN}▸${C_NC} $*"; }
warn()  { echo -e "${C_YELLOW}⚠${C_NC} $*"; }
error() { echo -e "${C_RED}✗${C_NC} $*"; exit 1; }

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
is_mac()   { [[ "$OSTYPE" == darwin* ]]; }
is_linux() { [[ "$OSTYPE" == linux* ]]; }
is_wsl()   { grep -qi microsoft /proc/version 2>/dev/null; }

detect_os() {
    if is_mac; then echo macos
    elif is_wsl; then echo wsl
    elif is_linux; then echo linux
    else error "Unsupported OS: $OSTYPE"
    fi
}

# ============================================================
# Install chezmoi
# ============================================================
install_chezmoi() {
    if command -v chezmoi >/dev/null; then
        return
    fi

    info "Installing chezmoi..."

    if is_mac && command -v brew >/dev/null; then
        brew install chezmoi
    else
        mkdir -p "$HOME/.local/bin"
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# ============================================================
# Configure chezmoi
# ============================================================
configure_chezmoi() {
    local cfg="$HOME/.config/chezmoi/chezmoi.toml"

    if [[ -f "$cfg" ]]; then
        info "Using existing chezmoi config"
        return
    fi

    [[ -z "$USER_NAME"  ]] && read -rp "Name: "  USER_NAME
    [[ -z "$USER_EMAIL" ]] && read -rp "Email: " USER_EMAIL

    mkdir -p "$(dirname "$cfg")"

    cat >"$cfg" <<EOF
[data]
name = "$USER_NAME"
email = "$USER_EMAIL"
EOF

    info "Created chezmoi config"
}

# ============================================================
# Copy dotfiles (NO SUDO)
# ============================================================
copy_dotfiles() {
    local src dest
    src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    dest="$HOME/.local/share/chezmoi"

    info "Installing dotfiles to $dest"

    rm -rf "$dest"
    mkdir -p "$dest"
    cp -R "$src/." "$dest/"

    if [[ -d "$dest/.chezmoiscripts" ]]; then
        find "$dest/.chezmoiscripts" -type f -name "*.tmpl" -exec chmod +x {} \;
    fi

    info "Dotfiles copied"
}

# ============================================================
# Apply chezmoi
# ============================================================
apply_dotfiles() {
    info "Initializing chezmoi from local source"
    chezmoi init --force --source="$HOME/.local/share/chezmoi"

    echo
    info "Previewing changes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    chezmoi diff || true
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    read -rp "Apply changes? (y/n) " -n 1
    echo
    [[ "$REPLY" =~ ^[Yy]$ ]] || { warn "Skipped"; return; }

    chezmoi apply -v
}

# ============================================================
# Setup shell (system changes only here)
# ============================================================
setup_shell() {
    [[ "$SHELL" == *zsh ]] && return

    info "Configuring zsh"

    if ! command -v zsh >/dev/null; then
        info "Installing zsh"
        if is_mac; then
            brew install zsh
        else
            sudo apt-get update
            sudo apt-get install -y zsh
        fi
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"

    if ! grep -qxF "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    sudo chsh -s "$zsh_path" "$USER"

    warn "Log out and back in for shell change to take effect"
}

# ============================================================
# Main
# ============================================================
main() {
    banner
    info "Detected OS: $(detect_os)"
    echo

    install_chezmoi
    configure_chezmoi
    copy_dotfiles
    apply_dotfiles
    setup_shell

    echo
    info "✓ Setup complete"
    echo
}

main "$@"