# backup.sh
#!/bin/bash
source "./utils.sh"

print_status "Starting backup of development environment"

# Create configs directory if it doesn't exist
mkdir -p configs/{vscode,zsh,git,iterm}

# Backup VSCode settings
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
if [ -d "$VSCODE_DIR" ]; then
    print_status "Backing up VSCode configuration"
    cp -R "$VSCODE_DIR/settings.json" "configs/vscode/" 2>/dev/null
    cp -R "$VSCODE_DIR/keybindings.json" "configs/vscode/" 2>/dev/null
    cp -R "$VSCODE_DIR/snippets" "configs/vscode/" 2>/dev/null
    
    if command -v code >/dev/null 2>&1; then
        code --list-extensions > "configs/vscode/extensions.txt"
    fi
fi

# Backup Zsh configuration
print_status "Backing up Zsh configuration"
cp "$HOME/.zshrc" "configs/zsh/" 2>/dev/null
cp "$HOME/.zshenv" "configs/zsh/" 2>/dev/null
cp "$HOME/.p10k.zsh" "configs/zsh/" 2>/dev/null

# Backup Oh My Zsh custom files if they exist
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ -d "$ZSH_CUSTOM" ]; then
    mkdir -p "configs/zsh/custom"
    cp -R "$ZSH_CUSTOM/themes" "configs/zsh/custom/" 2>/dev/null
    cp -R "$ZSH_CUSTOM/plugins" "configs/zsh/custom/" 2>/dev/null
    cp -R "$ZSH_CUSTOM/"*.zsh "configs/zsh/custom/" 2>/dev/null
fi

# Backup Git configuration
print_status "Backing up Git configuration"
cp "$HOME/.gitconfig" "configs/git/" 2>/dev/null
cp "$HOME/.gitignore_global" "configs/git/" 2>/dev/null

# Backup iTerm2 settings
print_status "Backing up iTerm2 configuration"
if [ -d "$HOME/Library/Application Support/iTerm2" ]; then
    cp -R "$HOME/Library/Application Support/iTerm2/DynamicProfiles" "configs/iterm/" 2>/dev/null
fi

print_status "Backup completed! Configurations stored in ./configs directory"
