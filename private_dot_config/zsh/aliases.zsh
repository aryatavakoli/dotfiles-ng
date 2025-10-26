#!/usr/bin/env zsh
# Aliases

# Modern CLI tools (with fallbacks)
command -v eza &>/dev/null && alias ls='eza' || alias ls='ls --color=auto'
command -v bat &>/dev/null && alias cat='bat'
command -v curlie &>/dev/null && alias curl='curlie'
command -v tofu &>/dev/null && alias terraform='tofu'
command -v doggo &>/dev/null && alias dig='doggo'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Enhanced ls (if eza available)
if command -v eza &>/dev/null; then
    alias ll='eza -lh --git'
    alias la='eza -lha --git'
    alias lt='eza -lh --sort=modified'
    alias tree='eza --tree'
else
    alias ll='ls -lh'
    alias la='ls -lha'
    alias lt='ls -lht'
fi

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Git
alias g='git'
alias gst='git status -sb'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gco='git checkout'
alias gph='git push'
alias gpl='git pull'
alias glg='git log --graph --oneline --decorate --all'
alias gdf='git diff'
alias gds='git diff --staged'

# Kubectl
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kctx='kubectx'
alias kns='kubens'

# Dotfiles (chezmoi)
alias dot-edit='chezmoi edit'
alias dot-apply='chezmoi apply -v'
alias dot-diff='chezmoi diff'
alias dot-status='chezmoi status'
alias dot-update='chezmoi update -v'
alias dot-cd='cd ~/.local/share/chezmoi'
alias dot-sync='chezmoi apply -v && exec zsh'

# Utils
alias reload='exec zsh'
alias path='echo -e ${PATH//:/\\n}'
alias myip='curl -s https://api.ipify.org; echo'
alias home='cd'


