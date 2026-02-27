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

    local brew_cmd="brew"
    if is_linux && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        brew_cmd="/home/linuxbrew/.linuxbrew/bin/brew"
    fi

    if is_mac && command -v brew >/dev/null; then
        brew install chezmoi
    elif is_linux && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        $brew_cmd install chezmoi
    else
        mkdir -p "$HOME/.local/bin"
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# ============================================================
# Homebrew helper (macOS)
# ============================================================

install_brew() {
    # idempotent installer for Homebrew
    if command -v brew >/dev/null; then
        info "Homebrew already installed"
        return
    fi

    info "Installing Homebrew..."
    # the official installation script is idempotent and will
    # harmlessly exit if brew is already present, but we guard above
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # On Linux (non-macOS), add Homebrew to PATH
    if is_linux; then
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    fi
    
    info "Homebrew installation complete"
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
        # make sure brew exists before trying to use it
        install_brew
        
        local brew_cmd="brew"
        if is_linux && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            brew_cmd="/home/linuxbrew/.linuxbrew/bin/brew"
        fi
        $brew_cmd install zsh
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"

    if ! grep -qxF "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    sudo chsh -s "$zsh_path" "$(whoami)"

    warn "Log out and back in for shell change to take effect"
}

# ============================================================
# Main
# ============================================================
main() {
    banner
    info "Detected OS: $(detect_os)"
    echo

    # on macOS and Linux we want Homebrew available before any brew-based
    # installs. this step is safe to run repeatedly.
    if is_mac || is_linux; then
        install_brew
    fi

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