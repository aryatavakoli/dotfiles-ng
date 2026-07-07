# Dotfiles

Chezmoi-managed dotfiles for macOS and Linux.

## Quick Start

```bash
git clone https://github.com/aryatavakoli/dotfiles-ng.git ~/dotfiles-ng
cd ~/dotfiles-ng
./install.sh
```

The installer: installs Homebrew + chezmoi, prompts for your name/email, applies all dotfiles, and sets zsh as the default shell.

## Package Management

All packages live in a single [Brewfile](.chezmoipackages/Brewfile) — `brew` formulae, `cask` apps (macOS only), and `vscode` extensions. The sync script runs automatically whenever the Brewfile changes.

**Sync is additive by default** — a plain apply never uninstalls anything you installed manually.

### Adding packages

```bash
dot-pkg-add brew htop        # inserts into the right section
dot-pkg-add cask firefox
dot-pkg-add vscode ms-python.python
dot-apply                    # installs it
```

### Removing packages

```bash
dot-pkg-remove brew htop     # drops the line
dot-pkg-sync                 # installs missing + prompts before pruning
```

### Flags

| Flag | Effect |
|------|--------|
| `DOTFILES_PRUNE=1` | Remove packages not in the Brewfile |
| `DOTFILES_UPGRADE=1` | Upgrade already-installed formulae |

## Structure

```
├── .chezmoipackages/Brewfile          # All packages
├── .chezmoiscripts/
│   ├── run_onchange_after_install-packages.sh.tmpl
│   └── run_once_after_initial-setup.sh.tmpl
├── private_dot_config/zsh/
│   ├── path.zsh                       # PATH
│   ├── env.zsh                        # Environment vars
│   ├── aliases.zsh                    # Aliases
│   ├── functions.zsh                  # Functions + pkg helpers
│   ├── plugins.zsh                    # Zinit plugins
│   ├── interactive.zsh                # mcfly / fzf / zoxide (sourced last)
│   └── p10k.zsh                       # Powerlevel10k config
├── private_Library/                   # VS Code settings (macOS only)
├── dot_zshrc                          # Shell entry point
├── dot_gitconfig.tmpl                 # Git config (templated name/email)
├── dot_gitignore                      # Global gitignore
├── dot_editorconfig                   # Editor config
└── install.sh
```

## Daily Usage

```bash
dot-apply          # chezmoi apply -v
dot-sync           # apply + exec zsh (reload shell)
dot-diff           # preview pending changes
dot-edit <file>    # open file in chezmoi edit
dot-cd             # cd to chezmoi source dir
dot-pkg-sync       # full reconcile with prune prompt
```

## Troubleshooting

**Force re-run scripts** (e.g. to reinstall Zinit):
```bash
rm ~/.local/share/chezmoi/.chezmoistate.boltdb
chezmoi apply -v
```

**Full reset:**
```bash
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi
./install.sh
```