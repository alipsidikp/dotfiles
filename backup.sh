#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

BACKUP_DIR="$HOME/.dotfiles_backup"
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"

print_status() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Backup Zsh configuration and customizations
backup_zsh() {
    print_status "Backing up Zsh configuration"
    
    # Main Zsh config
    mkdir -p "$BACKUP_DIR/zsh"
    cp -R "$HOME/.zshrc" "$BACKUP_DIR/zsh/" 2>/dev/null
    cp -R "$HOME/.zshenv" "$BACKUP_DIR/zsh/" 2>/dev/null
    cp -R "$HOME/.zprofile" "$BACKUP_DIR/zsh/" 2>/dev/null
    
    # Oh My Zsh custom directory
    if [ -d "$ZSH_CUSTOM_DIR" ]; then
        mkdir -p "$BACKUP_DIR/zsh/custom"
        # Custom themes
        cp -R "$ZSH_CUSTOM_DIR/themes" "$BACKUP_DIR/zsh/custom/" 2>/dev/null
        # Custom plugins
        cp -R "$ZSH_CUSTOM_DIR/plugins" "$BACKUP_DIR/zsh/custom/" 2>/dev/null
        # Custom aliases and functions
        cp -R "$ZSH_CUSTOM_DIR/aliases.zsh" "$BACKUP_DIR/zsh/custom/" 2>/dev/null
        cp -R "$ZSH_CUSTOM_DIR/functions.zsh" "$BACKUP_DIR/zsh/custom/" 2>/dev/null
    fi
    
    # Powerlevel10k theme configuration if exists
    if [ -f "$HOME/.p10k.zsh" ]; then
        cp "$HOME/.p10k.zsh" "$BACKUP_DIR/zsh/" 2>/dev/null
    fi
    
    # Save list of installed Zsh plugins
    if [ -f "$HOME/.zshrc" ]; then
        grep "^plugins=" "$HOME/.zshrc" > "$BACKUP_DIR/zsh/plugins.txt"
    fi
}

# Backup VSCode configuration
backup_vscode() {
    print_status "Backing up VSCode configuration"
    
    if [ -d "$VSCODE_DIR" ]; then
        mkdir -p "$BACKUP_DIR/vscode"
        
        # Backup all VSCode settings
        cp -R "$VSCODE_DIR/settings.json" "$BACKUP_DIR/vscode/" 2>/dev/null
        cp -R "$VSCODE_DIR/keybindings.json" "$BACKUP_DIR/vscode/" 2>/dev/null
        cp -R "$VSCODE_DIR/snippets" "$BACKUP_DIR/vscode/" 2>/dev/null
        
        # Backup integrated terminal settings
        if [ -f "$VSCODE_DIR/settings.json" ]; then
            # Extract terminal-specific settings
            grep -A 20 "terminal" "$VSCODE_DIR/settings.json" > "$BACKUP_DIR/vscode/terminal-settings.txt"
        fi
        
        # Backup extensions with versions
        if command -v code >/dev/null 2>&1; then
            # Get detailed extension info including versions
            code --list-extensions --show-versions > "$BACKUP_DIR/vscode/extensions-versions.txt"
            # Get just extension IDs for easier installation
            code --list-extensions > "$BACKUP_DIR/vscode/extensions.txt"
        fi
    fi
}

# Create restore script
create_restore_script() {
    print_status "Creating restore script"
    
    cat > "$BACKUP_DIR/restore.sh" << 'EOL'
#!/bin/bash

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Restore Zsh configuration
restore_zsh() {
    # Restore main Zsh configs
    cp -R zsh/.zshrc "$HOME/" 2>/dev/null
    cp -R zsh/.zshenv "$HOME/" 2>/dev/null
    cp -R zsh/.zprofile "$HOME/" 2>/dev/null
    
    # Restore Oh My Zsh customs
    if [ -d "zsh/custom" ]; then
        cp -R zsh/custom/* "$HOME/.oh-my-zsh/custom/" 2>/dev/null
    fi
    
    # Restore p10k config if exists
    if [ -f "zsh/.p10k.zsh" ]; then
        cp "zsh/.p10k.zsh" "$HOME/" 2>/dev/null
    fi
}

# Restore VSCode configuration
restore_vscode() {
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    mkdir -p "$VSCODE_DIR"
    
    # Restore VSCode settings
    cp -R vscode/settings.json "$VSCODE_DIR/" 2>/dev/null
    cp -R vscode/keybindings.json "$VSCODE_DIR/" 2>/dev/null
    cp -R vscode/snippets "$VSCODE_DIR/" 2>/dev/null
    
    # Install extensions
    if [ -f "vscode/extensions.txt" ]; then
        while IFS= read -r extension; do
            code --install-extension "$extension"
        done < "vscode/extensions.txt"
    fi
}

# Main restore process
echo "Restoring Zsh configuration..."
restore_zsh

echo "Restoring VSCode configuration..."
restore_vscode

echo "Restore completed!"
EOL

    chmod +x "$BACKUP_DIR/restore.sh"
}

# Main execution
main() {
    mkdir -p "$BACKUP_DIR"
    
    backup_zsh
    backup_vscode
    create_restore_script
    
    print_status "Backup completed in $BACKUP_DIR"
    echo "To restore on a new machine:"
    echo "1. Copy the $BACKUP_DIR directory to the new machine"
    echo "2. Run ./restore.sh in the backup directory"
}

main