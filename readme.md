# macOS Dotfiles

A comprehensive, idempotent setup for macOS development environments with focus on Go development, Kubernetes, Git with GPG signing, and a modern terminal experience.

## Overview

This repository contains configuration files and setup scripts for a complete macOS development environment. It's designed to be:

- **Idempotent**: Run it multiple times without breaking anything
- **Modular**: Easy to add or remove components
- **Comprehensive**: Sets up everything from command line tools to application preferences
- **Secure**: Includes GPG setup for signed Git commits
- **Developer-Friendly**: Optimized for Go, Kubernetes, and modern web development

## Repository Structure

```
.
├── README.md               # This file
├── setup.sh                # Main setup script
├── link-dotfiles.sh        # Script to link dotfiles to home directory
├── brew/                   # Homebrew related files
│   └── Brewfile            # Homebrew packages and applications to install
├── configs/                # Configuration files for various tools
│   ├── git/                # Git configuration
│   ├── vscode/             # VS Code configuration 
│   └── zsh/                # Zsh configuration
├── gpg/                    # GPG keys and configuration
│   ├── README.md           # Instructions for GPG setup
│   └── gpg-key.asc         # Your exported GPG key (you need to add this)
└── vscode/                 # VS Code specific files
    ├── settings.json       # VS Code settings
    ├── keybindings.json    # VS Code keyboard shortcuts
    └── extensions.txt      # List of VS Code extensions to install
```

## Prerequisites

- macOS (tested on Catalina and later)
- Internet connection
- Administrator privileges

## Quick Start

### Option 1: Clone and Setup

```bash
git clone https://github.com/alipsidikp/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x *.sh
./setup.sh
```

### Option 2: Bare Git Repository (Advanced)

```bash
git clone --bare https://github.com/alipsidikp/dotfiles.git $HOME/.cfg
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
cd ~/dotfiles
./setup.sh
```

## What Gets Installed

### Command Line Tools
- Xcode Command Line Tools
- Homebrew
- Git with GPG signing
- Shell: Zsh with Oh My Zsh
- Terminal improvements: fzf, ripgrep, bat, htop, tmux, direnv
- Modern alternatives: bat (cat), fd (find), ripgrep (grep)

### Programming Languages & Tools
- Go with extensive tooling:
  - gopls, goimports, golangci-lint, delve (debugger)
  - air (live reload), gotests, mockgen, gomodifytags
  - golang-migrate for database migrations
- Node.js with NVM for version management
- Python with user-local packages
- Rust

### Kubernetes Ecosystem
- kubectl with plugins via krew
- k9s for terminal UI
- helm, kustomize, kubectx, stern
- kind for local clusters

### Applications
- Visual Studio Code with extensions and configuration
- iTerm2 with improved configuration
- Docker Desktop
- Development-focused browsers
- Database tools (TablePlus)
- Window management (Rectangle, Alfred/Raycast)

### Shell Environment
- Zsh with Oh My Zsh
- Powerlevel10k theme
- Essential plugins:
  - zsh-autosuggestions, zsh-syntax-highlighting
  - git, kubectl, golang integrations
- Comprehensive PATH management
- Useful aliases and functions

## Detailed Usage

### Setup Script

The main `setup.sh` script handles the entire installation and configuration process:

```bash
./setup.sh
```

This will:
1. Install Xcode Command Line Tools if missing
2. Install and configure Homebrew
3. Set zsh as the default shell
4. Install packages from Brewfile
5. Install Oh My Zsh, Powerlevel10k, and plugins
6. Link all dotfiles to your home directory
7. Configure Git with your user information
8. Set up GPG for commit signing
9. Configure VS Code with settings and extensions
10. Set up Go development environment with enhanced tooling
11. Configure Kubernetes tools and plugins
12. Set up direnv for environment management
13. Configure NVM for Node.js version management
14. Create aliases and helper functions

### Linking Dotfiles Only

If you've already run the setup script and just want to update your configuration files:

```bash
./link-dotfiles.sh
```

### Updating Your Environment

To update your environment after changes to the repository:

```bash
cd ~/dotfiles
git pull
./link-dotfiles.sh
```

## Customization

### Adding Homebrew Packages

Edit `brew/Brewfile` to add new packages or applications:

```ruby
# CLI Tools
brew "your-new-package"

# Applications
cask "your-new-app"
```

Then run:

```bash
cd ~/dotfiles
brew bundle --file="$(pwd)/brew/Brewfile"
```

### Adding VS Code Extensions

Edit `vscode/extensions.txt` to add new extensions, then run:

```bash
cd ~/dotfiles
while IFS= read -r extension; do
    [[ "$extension" =~ ^# ]] || code --install-extension "$extension" --force
done < "$(pwd)/vscode/extensions.txt"
```

### Local Customizations

For machine-specific configurations that shouldn't be in the repository:

1. Edit `~/.zshrc.local` - This file is automatically loaded but not tracked in git
2. Use `direnv` for project-specific environment variables:
   ```bash
   echo "export API_KEY=your_secret_key" > .envrc
   direnv allow
   ```

## Key Features

### Kubernetes Development

This setup includes a comprehensive Kubernetes development environment:

- kubectl with autocomplete and aliases
- krew plugin manager with essential plugins
- k9s for terminal-based cluster management
- Useful aliases and functions for kubectl commands
- VSCode extensions for Kubernetes

Example aliases:
```bash
k         # kubectl
kctx      # kubectl config use-context
kns       # kubectl config set-context --current --namespace
kgp       # kubectl get pods
```

### Go Development

Enhanced Go development environment:

- GOPATH and GOROOT properly configured
- Essential Go tools pre-installed
- golangci-lint with sensible defaults
- VS Code configured for Go development
- Hot-reload capabilities with air

### ZSH Features

The ZSH configuration includes:

- Intelligent PATH management
- Autocomplete for tools like git, kubectl, docker
- Syntax highlighting and suggestions
- Custom prompt with git status
- Directory-specific environment variables via direnv

## Troubleshooting

### Homebrew Installation Issues

If Homebrew installation fails, try running the following:

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### GPG Issues

If you encounter GPG issues:

1. Ensure your GPG key is properly exported to `gpg/gpg-key.asc`
2. Check your GPG agent configuration:
   ```bash
   echo "pinentry-program /usr/local/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
   killall gpg-agent
   gpg-agent --daemon
   ```

### Zsh Configuration

If your zsh configuration isn't loading correctly:

```bash
# Regenerate zsh completion cache
rm -f ~/.zcompdump*
compinit

# Check if Oh My Zsh is properly installed
ls -la ~/.oh-my-zsh
```

### Kubernetes Setup

If kubectl plugins aren't working:

```bash
# Verify krew installation
kubectl krew

# Ensure PATH includes krew
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.zshrc.local
source ~/.zshrc
```

## Contributing

Feel free to fork this repository and customize it for your own needs. If you have any improvements or bug fixes, please open an issue or a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.