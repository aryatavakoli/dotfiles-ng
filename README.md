# Dotfiles (Chezmoi)

Clean, automated dotfile management with **automatic package synchronization** for **macOS** and **Linux**.

## ✨ Features

- 🚀 **One-command setup** - Install everything with a single script
- 📦 **Automatic package sync** - Brew, casks, and VS Code extensions stay in sync
- 🔄 **Smart change detection** - Only updates when package lists change
- 🗑️  **Removal support** - Tracks and removes packages no longer in your list
- 🖥️  **Cross-platform** - Works seamlessly on macOS, Linux, and WSL
- 🎨 **Powerlevel10k theme** - Beautiful, fast zsh prompt
- 📝 **Templated configs** - Git config uses your name/email
- 🧩 **Modular structure** - Separate files for aliases, functions, env vars

## Quick Start

```bash
# Clone and install
cd ~/dotfiles/chezmoi
chmod +x install.sh
./install.sh
```

The installer will:
1. Install chezmoi
2. Detect your OS (macOS/Linux/WSL)
3. Install Homebrew (if not present)
4. Copy and apply your dotfiles
5. Install all packages automatically
6. Set up zsh with Powerlevel10k

## 📦 Package Management

Packages are automatically synced from simple text files in `.chezmoipackages/`:

```
.chezmoipackages/
├── brew.txt      # Homebrew formulae (one per line)
├── cask.txt      # Homebrew casks (macOS only)
└── vscode.txt    # VS Code extensions
```

### Adding Packages

**Option 1: Use helper function**
```bash
dot-pkg-add brew htop
dot-pkg-add cask firefox
dot-pkg-add vscode ms-python.python
dot-apply  # Automatically installs!
```

**Option 2: Edit directly**
```bash
echo "htop" >> ~/.local/share/chezmoi/.chezmoipackages/brew.txt
chezmoi apply -v  # Automatically installs htop!
```

**Option 3: Use chezmoi edit**
```bash
chezmoi edit ~/.local/share/chezmoi/.chezmoipackages/brew.txt
chezmoi apply -v
```

### Removing Packages

**Option 1: Use helper function**
```bash
dot-pkg-remove brew htop
dot-apply  # Automatically uninstalls!
```

**Option 2: Delete the line manually**
```bash
chezmoi edit ~/.local/share/chezmoi/.chezmoipackages/brew.txt
# Delete the "htop" line
chezmoi apply -v  # Automatically uninstalls htop!
```

The sync script:
- ✅ **Installs** packages that are in the list but not on your system
- ✅ **Removes** packages that were managed but are no longer in the list
- ✅ **Skips** packages that are already installed
- ✅ **Shows progress** with clear status indicators

### How It Works

The `run_onchange_before_install-packages.sh.tmpl` script:
1. Calculates a hash of each package file
2. Runs automatically when the hash changes
3. Compares current packages with desired state
4. Installs missing packages
5. Removes packages no longer in the list
6. Saves state for next time

**State tracking:** Package lists are saved in `~/.cache/chezmoi-packages/` to track what was installed by chezmoi.

## 🗂️ Structure

```
chezmoi/
├── .chezmoipackages/                  # Package lists
│   ├── brew.txt                       # Homebrew formulae
│   ├── cask.txt                       # Homebrew casks (macOS)
│   └── vscode.txt                     # VS Code extensions
├── .chezmoiscripts/                   # Automated scripts
│   ├── run_onchange_before_install-packages.sh.tmpl  # Package sync
│   └── run_once_after_initial-setup.sh.tmpl          # Initial setup
├── private_dot_config/
│   ├── zsh/                           # Modular shell config
│   │   ├── path.zsh                   # PATH setup (OS-aware)
│   │   ├── env.zsh                    # Environment vars
│   │   ├── aliases.zsh                # Aliases
│   │   ├── functions.zsh              # Functions
│   │   └── antigen.zsh                # Plugins (OS-aware)
│   └── chezmoi/                       # Chezmoi config
│       └── chezmoi.toml.tmpl          # Chezmoi settings
├── private_Library/                   # VSCode settings (macOS)
├── dot_zshrc                          # Main zsh entry point
├── dot_gitconfig.tmpl                 # Git config (templated)
├── dot_editorconfig                   # Editor config
├── dot_p10k.zsh                       # Powerlevel10k theme
└── install.sh                         # Setup script
```

## 💻 Daily Usage

```bash
# Edit dotfiles
chezmoi edit ~/.zshrc
chezmoi diff              # See what would change
chezmoi apply -v          # Apply changes

# Or use the included aliases
dot-edit ~/.zshrc
dot-diff
dot-apply
dot-sync                 # Apply + reload shell
```

### Reconfigure Theme

```bash
p10k configure
# Changes are automatically saved to ~/.p10k.zsh (tracked by chezmoi)
```

## 🔧 Troubleshooting

**Re-run package installation:**
```bash
# Trigger package sync
chezmoi apply -v
```

**Force re-run of all scripts:**
```bash
rm ~/.local/share/chezmoi/.chezmoistate.boltdb
chezmoi apply -v
```

**Complete reset:**
```bash
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi ~/.cache/chezmoi-packages
./install.sh
```

**View installed packages:**
```bash
brew list                 # Homebrew formulae
brew list --cask          # Homebrew casks (macOS)
code --list-extensions    # VS Code extensions
```

## 🚀 Why Chezmoi?

**Better than Dotbot:**
- ✅ Built-in diff and templating
- ✅ Automatic change detection
- ✅ Cleaner, more maintainable code
- ✅ Active development and community
- ✅ Better cross-platform support
- ✅ Smart package removal support

**All Dotbot functionality preserved:**
- ✓ Shell config (zshrc, aliases, functions, exports, path)
- ✓ Brew/cask/VS Code automation
- ✓ Antigen + Powerlevel10k
- ✓ Git/Editor config

## 📚 Learn More

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Homebrew](https://brew.sh/)
