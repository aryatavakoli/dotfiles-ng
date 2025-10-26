#!/usr/bin/env zsh
# Custom functions

# Dig with useful output
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Open current dir or specified location
o() {
    [[ $# -eq 0 ]] && open . || open "$@"
}

# Tree with exclusions
tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find files by pattern
findfile() {
    find . -type f -iname "*${1}*" 2>/dev/null
}

# Show largest files/directories
largest() {
    du -sh * 2>/dev/null | sort -hr | head -10
}

# Backup with timestamp
backup() {
    cp -r "$1" "${1}.bak_$(date +%Y%m%d_%H%M%S)"
}

# Cross-platform open command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS uses 'open' natively, do nothing
    :
elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL
    alias open='explorer.exe'
elif command -v xdg-open &>/dev/null; then
    # Linux with xdg-open
    alias open='xdg-open'
fi

# Package management
dot-pkg-add() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: dot-pkg-add {brew|cask|vscode} <package-name>"
        return 1
    fi
    
    local type="$1"
    local package="$2"
    local file="$HOME/.local/share/chezmoi/.chezmoipackages/${type}.txt"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Invalid type: $type"
        echo "Usage: dot-pkg-add {brew|cask|vscode} <package-name>"
        return 1
    fi
    
    # Check if package already exists
    if grep -qx "$package" "$file" 2>/dev/null; then
        echo "⚠️  Package '$package' already in $type.txt"
        return 0
    fi
    
    echo "$package" >> "$file"
    echo "✓ Added '$package' to $type.txt"
    echo "→ Run: dot-apply"
}

dot-pkg-list() {
    local dir="$HOME/.local/share/chezmoi/.chezmoipackages"
    
    for type in brew cask vscode; do
        echo "=== ${type:u} ==="
        cat "$dir/$type.txt" 2>/dev/null | sort
        echo
    done
}

# Remove package from list
dot-pkg-remove() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: dot-pkg-remove {brew|cask|vscode} <package-name>"
        return 1
    fi
    
    local type="$1"
    local package="$2"
    local file="$HOME/.local/share/chezmoi/.chezmoipackages/${type}.txt"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Invalid type: $type"
        return 1
    fi
    
    if ! grep -qx "$package" "$file" 2>/dev/null; then
        echo "⚠️  Package '$package' not found in $type.txt"
        return 0
    fi
    
    # Remove the package
    grep -vx "$package" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    echo "✓ Removed '$package' from $type.txt"
    echo "→ Run: dot-apply (will uninstall the package)"
}

# Quick edit chezmoi source files
dot-src() {
    cd "$HOME/.local/share/chezmoi" || return 1
}

