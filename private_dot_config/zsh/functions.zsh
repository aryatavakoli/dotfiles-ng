#!/usr/bin/env zsh
# Custom functions

# Dig with useful output (bypasses any alias)
digga() {
    command dig +nocmd "$1" any +multiline +noall +answer
}

# Open current dir or specified location
o() {
    [[ $# -eq 0 ]] && open . || open "$@"
}

# Tree with exclusions (uses real tree binary, not eza alias)
tre() {
    command tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find files by pattern (uses fd if available)
findfile() {
    if command -v fd &>/dev/null; then
        fd --type f "$1"
    else
        find . -type f -iname "*${1}*" 2>/dev/null
    fi
}

# Show largest files/directories
largest() {
    du -sh "${@:-.}"/* 2>/dev/null | sort -hr | head -20
}

# Backup with timestamp (preserves attributes; handles files and dirs)
backup() {
    [[ -e "$1" ]] || { echo "backup: '$1' does not exist"; return 1; }
    cp -a "$1" "${1%/}.bak_$(date +%Y%m%d_%H%M%S)"
}

# Cross-platform open command
if [[ "$OSTYPE" == "darwin"* ]]; then
    :
elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    alias open='explorer.exe'
elif command -v xdg-open &>/dev/null; then
    alias open='xdg-open'
fi

# Helm Render
hrend() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: hrend <chart-dir> <release-name> [extra-values...]"
        return 1
    fi
    local args=(-f "$1/values.yaml")
    for f in "${@:3}"; do args+=(-f "$f"); done
    helm template "$2" "$1" "${args[@]}" > "rendered-$2.yaml" && echo "Rendered to rendered-$2.yaml"
}
# Alias for muscle memory; hrend auto-includes the chart's values.yaml.
alias helm-render='hrend'

# Package management (Brewfile-based)
dot-pkg-add() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: dot-pkg-add {brew|cask|vscode} <package-name>"
        return 1
    fi

    local type="$1"
    local package="$2"
    local brewfile="$HOME/.local/share/chezmoi/.chezmoipackages/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile not found at $brewfile"
        return 1
    fi

    case "$type" in
        brew|cask|vscode) local entry="$type \"$package\"" ;;
        *)      echo "Invalid type: $type (valid: brew, cask, vscode)"; return 1 ;;
    esac

    if grep -qxF "$entry" "$brewfile" 2>/dev/null; then
        echo "Already in Brewfile: $entry"
        return 0
    fi

    # Insert after the last existing entry of the same type to keep sections grouped;
    # fall back to appending if this is the first entry of its type.
    local last_line
    last_line=$(grep -n "^${type} " "$brewfile" | tail -1 | cut -d: -f1)

    if [[ -n "$last_line" ]]; then
        awk -v n="$last_line" -v e="$entry" 'NR==n{print; print e; next} {print}' \
            "$brewfile" > "${brewfile}.tmp" && mv "${brewfile}.tmp" "$brewfile"
    else
        echo "$entry" >> "$brewfile"
    fi
    echo "Added to Brewfile: $entry — run: dot-apply"
}

dot-pkg-remove() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: dot-pkg-remove {brew|cask|vscode} <package-name>"
        return 1
    fi

    local type="$1"
    local package="$2"
    local brewfile="$HOME/.local/share/chezmoi/.chezmoipackages/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile not found at $brewfile"
        return 1
    fi

    case "$type" in
        brew)   local pattern="brew \"$package\"" ;;
        cask)   local pattern="cask \"$package\"" ;;
        vscode) local pattern="vscode \"$package\"" ;;
        *)      echo "Invalid type: $type (valid: brew, cask, vscode)"; return 1 ;;
    esac

    # Match the whole line exactly (-x) so removing "fd" can't strip "fd-find".
    if ! grep -qxF "$pattern" "$brewfile" 2>/dev/null; then
        echo "Not found in Brewfile: $pattern"
        return 0
    fi

    grep -vxF "$pattern" "$brewfile" > "${brewfile}.tmp" && mv "${brewfile}.tmp" "$brewfile"
    echo "Removed from Brewfile: $pattern — run: dot-apply"
}

dot-pkg-list() {
    local brewfile="$HOME/.local/share/chezmoi/.chezmoipackages/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile not found"
        return 1
    fi

    echo "=== BREW ==="
    grep '^brew ' "$brewfile" | sed 's/brew "//;s/"//' | sort
    echo
    echo "=== CASK ==="
    grep '^cask ' "$brewfile" | sed 's/cask "//;s/"//' | sort
    echo
    echo "=== VSCODE ==="
    grep '^vscode ' "$brewfile" | sed 's/vscode "//;s/"//' | sort
    echo
}

dot-src() {
    cd "$HOME/.local/share/chezmoi" || return 1
}

# Deliberate full reconcile: install from Brewfile AND prune anything not in it.
# The auto-sync script is additive-only; use this when you actually want to
# remove packages that are no longer declared. Prompts before pruning.
dot-pkg-sync() {
    local brewfile="$HOME/.local/share/chezmoi/.chezmoipackages/Brewfile"
    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile not found at $brewfile"
        return 1
    fi

    local install_args=(--file="$brewfile" --no-upgrade)
    local cleanup_args=(--file="$brewfile")
    if [[ "$OSTYPE" != darwin* ]]; then
        export HOMEBREW_BUNDLE_NO_CASK=1
        export HOMEBREW_BUNDLE_NO_VSCODE=1
    fi

    echo "Installing anything missing from the Brewfile..."
    brew bundle "${install_args[@]}"

    echo
    echo "The following would be removed (not in the Brewfile):"
    brew bundle cleanup "${cleanup_args[@]}" || true

    echo
    read -q "REPLY?Remove these packages? (y/n) "
    echo
    if [[ "$REPLY" == [Yy] ]]; then
        brew bundle cleanup "${cleanup_args[@]}" --force
        brew autoremove 2>/dev/null || true
        echo "Prune complete."
    else
        echo "Skipped prune."
    fi
}
