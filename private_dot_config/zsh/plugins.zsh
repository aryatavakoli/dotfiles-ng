#!/usr/bin/env zsh
# Zinit plugin manager

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    echo "⚠ Zinit not found. Run: chezmoi apply -v"
    return
fi

source "$ZINIT_HOME/zinit.zsh"

# ============================================================
# Extra completion dirs (added to fpath before Zinit runs compinit).
# Each is a no-op if the directory doesn't exist, so this stays portable.
# ============================================================
for _comp_dir in \
    "$HOME/.docker/completions" \
    "$HOME/.local/share/zsh/site-functions"; do
    [[ -d "$_comp_dir" ]] && fpath=("$_comp_dir" $fpath)
done
unset _comp_dir

# ============================================================
# Theme — Powerlevel10k (loaded immediately for instant prompt)
# ============================================================
zinit ice depth=1
zinit light romkatv/powerlevel10k

# ============================================================
# Oh-my-zsh libraries & plugins (via snippets)
# git & kubectl aliases/completions come from these plugins.
# ============================================================
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::kubectl \
    OMZP::brew \
    OMZP::command-not-found \
    OMZP::colored-man-pages \
    OMZP::extract

# OS-specific plugins
case $(uname) in
    Darwin)
        # Note: OMZP::macos is intentionally omitted — it sources sibling
        # files (music/spotify) that Zinit can't fetch without svn.
        zinit wait lucid for OMZP::aws
        ;;
    Linux)
        zinit wait lucid for OMZP::docker OMZP::systemd
        ;;
esac

# ============================================================
# Community plugins (turbo-loaded for fast startup)
# ============================================================
zinit wait lucid for \
    atload"zicompinit; zicdreplay" blockf \
        zsh-users/zsh-completions \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search

# Syntax highlighting must load last
zinit wait lucid for \
    atinit"zpcompinit; zpcdreplay" \
        zdharma-continuum/fast-syntax-highlighting
