#!/usr/bin/env zsh
# PATH configuration

# Homebrew (macOS/Linux) - Load first for precedence
[[ -d "/opt/homebrew/bin" ]] && export PATH="/opt/homebrew/bin:$PATH"
[[ -d "/home/linuxbrew/.linuxbrew/bin" ]] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Base paths
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# Krew (kubectl plugins)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# VSCode CLI (macOS)
[[ "$OSTYPE" == "darwin"* ]] && \
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Remove duplicates
typeset -U PATH

