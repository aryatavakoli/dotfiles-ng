#!/usr/bin/env zsh
# Interactive-shell tool initialization.
# Sourced LAST (after plugins) so these tools' key bindings and widgets
# aren't clobbered by syntax-highlighting / autosuggestions / completion.

# McFly history search (takes over Ctrl-R)
if command -v mcfly &>/dev/null; then
    eval "$(mcfly init zsh)"
    # Let mcfly own Ctrl-R; disable fzf's history binding below
    export FZF_CTRL_R_COMMAND=""
fi

# fzf keybindings and completion
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh 2>/dev/null)" || {
        [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
    }
fi

# Zoxide (smart cd) — must be initialized at the very end of shell config
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi
