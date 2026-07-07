#!/usr/bin/env bash
# Dotfiles installer for macOS, Linux, and WSL
set -euo pipefail

# ============================================================
# Guards
# ============================================================
if [[ "$(id -u)" -eq 0 ]]; then
    echo "Do not run this script as root"
    exit 1
fi

# ============================================================
# Configuration
# ============================================================
FORCE="${NONINTERACTIVE:-false}"
for arg in "$@"; do
    case "$arg" in
        --force|-f) FORCE=true ;;
    esac
done

USER_NAME="${USER_NAME:-}"
USER_EMAIL="${USER_EMAIL:-}"

# ============================================================
# Colors & Logging
# ============================================================
C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'; C_NC='\033[0m'

info()  { echo -e "${C_GREEN}>${C_NC} $*"; }
warn()  { echo -e "${C_YELLOW}!${C_NC} $*"; }
error() { echo -e "${C_RED}x${C_NC} $*"; exit 1; }

banner() {
    echo -e "${C_BLUE}"
    echo "  Dotfiles Installation (Chezmoi)"
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
# Install Homebrew
# ============================================================
install_brew() {
    if command -v brew >/dev/null; then
        info "Homebrew already installed"
        return
    fi

    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if is_mac && [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif is_linux && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    info "Homebrew installation complete"
}

# ============================================================
# Install chezmoi
# ============================================================
install_chezmoi() {
    if command -v chezmoi >/dev/null; then
        return
    fi

    info "Installing chezmoi..."

    if command -v brew >/dev/null; then
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

    if [[ "$FORCE" != true ]]; then
        [[ -z "$USER_NAME"  ]] && read -rp "Name: "  USER_NAME
        [[ -z "$USER_EMAIL" ]] && read -rp "Email: " USER_EMAIL
    fi

    if [[ -z "$USER_NAME" || -z "$USER_EMAIL" ]]; then
        error "USER_NAME and USER_EMAIL must be set (or use interactive mode)"
    fi

    mkdir -p "$(dirname "$cfg")"

    cat >"$cfg" <<EOF
[data]
name = "$USER_NAME"
email = "$USER_EMAIL"
EOF

    info "Created chezmoi config"
}

# ============================================================
# Copy dotfiles
# ============================================================
copy_dotfiles() {
    local src dest
    src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    dest="$HOME/.local/share/chezmoi"

    # Nothing to do if we're already running from the chezmoi source dir.
    if [[ "$src" == "$dest" ]]; then
        info "Already running from chezmoi source dir; skipping copy"
        return
    fi

    # Guard against clobbering an existing source dir that has local work.
    if [[ -d "$dest/.git" && "$FORCE" != true ]]; then
        if ! git -C "$dest" diff --quiet --ignore-submodules HEAD 2>/dev/null \
           || [[ -n "$(git -C "$dest" status --porcelain 2>/dev/null)" ]]; then
            warn "$dest has uncommitted changes and would be overwritten."
            read -rp "Overwrite it anyway? (y/n) " -n 1
            echo
            [[ "$REPLY" =~ ^[Yy]$ ]] || error "Aborted to protect local changes in $dest"
        fi
    fi

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

    if [[ "$FORCE" != true ]]; then
        echo
        info "Previewing changes"
        chezmoi diff | cat || true
        echo

        read -rp "Apply changes? (y/n) " -n 1
        echo
        [[ "$REPLY" =~ ^[Yy]$ ]] || { warn "Skipped"; return; }
    fi

    chezmoi apply -v
}

# ============================================================
# Setup shell
# ============================================================
setup_shell() {
    [[ "$SHELL" == *zsh ]] && return

    info "Configuring zsh as default shell"

    if ! command -v zsh >/dev/null; then
        if command -v brew >/dev/null; then
            brew install zsh
        else
            error "zsh not found and no package manager available"
        fi
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"

    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    if [[ "$FORCE" == true ]]; then
        sudo chsh -s "$zsh_path" "$(whoami)" 2>/dev/null || \
            warn "Could not change shell (likely running in container)"
    else
        sudo chsh -s "$zsh_path" "$(whoami)"
    fi

    warn "Log out and back in for shell change to take effect"
}

# ============================================================
# Main
# ============================================================
main() {
    banner
    info "Detected OS: $(detect_os)"
    echo

    install_brew
    install_chezmoi
    configure_chezmoi
    copy_dotfiles
    apply_dotfiles
    setup_shell

    echo
    info "Setup complete"
    echo
}

main "$@"
