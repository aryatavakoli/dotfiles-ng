#!/usr/bin/env zsh
# Antigen plugin manager

antigen use oh-my-zsh

# Core plugins
antigen bundle git
antigen bundle kubectl
antigen bundle brew
antigen bundle zoxide
antigen bundle fzf
antigen bundle command-not-found
antigen bundle colored-man-pages
antigen bundle extract
antigen bundle terraform
antigen bundle ssh-agent

# Community plugins (must be after oh-my-zsh plugins)
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle unixorn/autoupdate-antigen.zshplugin

# OS-specific plugins
case $(uname) in
    Darwin)
        antigen bundle osx
        antigen bundle aws
        ;;
    Linux)
        antigen bundle docker
        antigen bundle docker-compose
        antigen bundle systemd
        ;;
esac

# Theme
antigen theme romkatv/powerlevel10k

# Apply configuration
antigen apply

# Enable command completion
autoload -Uz compinit
# Only check cache once a day for performance
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Load powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

