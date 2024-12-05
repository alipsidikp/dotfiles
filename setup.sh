#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup current setup
backup_current_setup() {
    print_status "Backing up current setup"
    
    BACKUP_DIR="$HOME/.dotfiles_backup"
    mkdir -p "$BACKUP_DIR"
    
    # Backup Shell configurations
    cp -R "$HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null
    cp -R "$HOME/.bash_profile" "$BACKUP_DIR/" 2>/dev/null
    cp -R "$HOME/.bashrc" "$BACKUP_DIR/" 2>/dev/null
    
    # Backup Git configuration
    cp -R "$HOME/.gitconfig" "$BACKUP_DIR/" 2>/dev/null
    
    # Backup VSCode settings
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    if [ -d "$VSCODE_DIR" ]; then
        mkdir -p "$BACKUP_DIR/vscode"
        cp -R "$VSCODE_DIR/settings.json" "$BACKUP_DIR/vscode/" 2>/dev/null
        cp -R "$VSCODE_DIR/keybindings.json" "$BACKUP_DIR/vscode/" 2>/dev/null
        cp -R "$VSCODE_DIR/snippets" "$BACKUP_DIR/vscode/" 2>/dev/null
        
        # Backup VSCode extensions list
        if command_exists code; then
            code --list-extensions > "$BACKUP_DIR/vscode/extensions.txt"
        fi
    fi
    
    # Backup Homebrew packages
    if command_exists brew; then
        brew bundle dump --force --file="$BACKUP_DIR/Brewfile"
    fi
    
    # Backup npm global packages
    if command_exists npm; then
        npm list -g --depth=0 > "$BACKUP_DIR/npm_packages.txt"
    fi
    
    # Backup pip packages
    if command_exists pip3; then
        pip3 freeze > "$BACKUP_DIR/requirements.txt"
    fi
    
    # Backup Go packages
    if command_exists go; then
        go list -m all > "$BACKUP_DIR/go_modules.txt"
    fi
}

# Install development tools
install_dev_tools() {
    print_status "Installing development tools"
    
    # Install Homebrew if not installed
    if ! command_exists brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install from Brewfile if exists
    if [ -f "$BACKUP_DIR/Brewfile" ]; then
        brew bundle --file="$BACKUP_DIR/Brewfile"
    else
        # Install common development tools
        brew install git node python go
    fi
    
    # Install Oh My Zsh if not installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

# Setup VSCode
setup_vscode() {
    print_status "Setting up VSCode"
    
    # Install VSCode if not installed
    if ! command_exists code; then
        brew install --cask visual-studio-code
    fi
    
    # Restore VSCode settings
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    if [ -d "$BACKUP_DIR/vscode" ]; then
        mkdir -p "$VSCODE_DIR"
        cp -R "$BACKUP_DIR/vscode/settings.json" "$VSCODE_DIR/" 2>/dev/null
        cp -R "$BACKUP_DIR/vscode/keybindings.json" "$VSCODE_DIR/" 2>/dev/null
        cp -R "$BACKUP_DIR/vscode/snippets" "$VSCODE_DIR/" 2>/dev/null
        
        # Install extensions
        if [ -f "$BACKUP_DIR/vscode/extensions.txt" ]; then
            while IFS= read -r extension; do
                code --install-extension "$extension"
            done < "$BACKUP_DIR/vscode/extensions.txt"
        fi
    fi
}

# Restore language-specific packages
restore_packages() {
    print_status "Restoring language-specific packages"
    
    # Restore npm packages
    if [ -f "$BACKUP_DIR/npm_packages.txt" ] && command_exists npm; then
        # Extract package names and install them globally
        sed -n 's/[├└]── \(.*\)@.*/\1/p' "$BACKUP_DIR/npm_packages.txt" | xargs -I {} npm install -g {}
    fi
    
    # Restore Python packages
    if [ -f "$BACKUP_DIR/requirements.txt" ] && command_exists pip3; then
        pip3 install -r "$BACKUP_DIR/requirements.txt"
    fi
    
    # Restore Go packages
    if [ -f "$BACKUP_DIR/go_modules.txt" ] && command_exists go; then
        while IFS= read -r module; do
            if [[ $module != "go.mod" ]]; then
                go get -u "$module"
            fi
        done < "$BACKUP_DIR/go_modules.txt"
    fi
}

# Main execution
case "$1" in
    "backup")
        backup_current_setup
        print_status "Backup completed in $BACKUP_DIR"
        ;;
    "restore")
        install_dev_tools
        setup_vscode
        restore_packages
        print_status "Restore completed"
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        echo "  backup  - Backup current setup"
        echo "  restore - Restore development environment"
        exit 1
        ;;
esac