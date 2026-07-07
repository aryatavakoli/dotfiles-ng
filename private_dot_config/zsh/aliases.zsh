#!/usr/bin/env zsh
# Aliases

# Modern CLI tools (with fallbacks)
if command -v eza &>/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -lh --git --icons=auto --group-directories-first'
    alias la='eza -lha --git --icons=auto --group-directories-first'
    alias lt='eza -lh --sort=modified --icons=auto --group-directories-first'
    alias tree='eza --tree --icons=auto'
elif [[ "$OSTYPE" == darwin* ]]; then
    alias ls='ls -G'
    alias ll='ls -lhG'
    alias la='ls -lhaG'
    alias lt='ls -lhtG'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lha --color=auto'
    alias lt='ls -lht --color=auto'
fi

command -v bat &>/dev/null && alias cat='bat'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# kubectx / kubens shortcuts (not part of the kubectl plugin)
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
alias myip='command curl -s https://api.ipify.org; echo'
alias home='cd'
