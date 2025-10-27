#!/usr/bin/env zsh
# Environment variables

# Editors & Pager
export EDITOR=nano
export VISUAL=nano
export PAGER=less

# History
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# History options
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Colors & Display
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export LESS="-R -M -i -j10"
export LESSHISTFILE="-"

# Performance: Skip compinit until antigen runs
skip_global_compinit=1

# Tools
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
export TENV_ARCH=amd64
export TENV_AUTO_INSTALL=true
export GODEBUG=asyncpreemptoff=1
export ZOXIDE_CMD_OVERRIDE=cd

