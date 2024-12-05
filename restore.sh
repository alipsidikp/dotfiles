# restore.sh
#!/bin/bash
source "./utils.sh"

install_tool() {
    if [ -f "./install/$1.sh" ]; then
        print_status "Installing $1"
        bash "./install/$1.sh"
    else
        print_error "Installation script for $1 not found"
    fi
}

restore_configs() {
    if [ ! -d "configs" ]; then
        print_error "No configs directory found. Run backup.sh first or pull from repository."
        exit 1
    fi

    print_status "Restoring configurations"
    
    # Restore VSCode settings
    if [ -d "configs/vscode" ]; then
        VSCODE_DIR="$HOME/Library/Application Support/Code/User"
        mkdir -p "$VSCODE_DIR"
        cp -R configs/vscode/settings.json "$VSCODE_DIR/" 2>/dev/null
        cp -R configs/vscode/keybindings.json "$VSCODE_DIR/" 2>/dev/null
        cp -R configs/vscode/snippets "$VSCODE_DIR/" 2>/dev/null
        
        # Install VSCode extensions
        if [ -f "configs/vscode/extensions.txt" ]; then
            while IFS= read -r extension; do
                code --install-extension "$extension"
            done < "configs/vscode/extensions.txt"
        fi
    fi
    
    # Restore Zsh configuration
    if [ -d "configs/zsh" ]; then
        cp configs/zsh/.zshrc "$HOME/" 2>/dev/null
        cp configs/zsh/.zshenv "$HOME/" 2>/dev/null
        cp configs/zsh/.p10k.zsh "$HOME/" 2>/dev/null
        
        # Restore Oh My Zsh custom files
        if [ -d "configs/zsh/custom" ]; then
            ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
            mkdir -p "$ZSH_CUSTOM"
            cp -R configs/zsh/custom/themes "$ZSH_CUSTOM/" 2>/dev/null
            cp -R configs/zsh/custom/plugins "$ZSH_CUSTOM/" 2>/dev/null
            cp -R configs/zsh/custom/*.zsh "$ZSH_CUSTOM/" 2>/dev/null
        fi
    fi
    
    # Restore Git configuration
    if [ -d "configs/git" ]; then
        cp configs/git/.gitconfig "$HOME/" 2>/dev/null
        cp configs/git/.gitignore_global "$HOME/" 2>/dev/null
    fi
    
    # Restore iTerm2 settings
    if [ -d "configs/iterm" ]; then
        ITERM_DIR="$HOME/Library/Application Support/iTerm2"
        mkdir -p "$ITERM_DIR"
        cp -R configs/iterm/DynamicProfiles "$ITERM_DIR/" 2>/dev/null
    fi
}

case "$1" in
    --core)
        install_tool "core"
        ;;
    --env)
        install_tool "zsh"
        restore_configs
        ;;
    --dev)
        install_tool "vscode"
        install_tool "iterm"
        restore_configs
        ;;
    --help)
        echo "Usage: $0 [OPTIONS]"
        echo "Options:"
        echo "  --core   Install only core tools (git, node, etc.)"
        echo "  --env    Install and configure Zsh environment"
        echo "  --dev    Install development tools (VSCode, iTerm)"
        echo "  --help   Show this help message"
        echo "  (no args) Full installation and configuration"
        exit 0
        ;;
    *)
        print_status "Performing full installation and configuration"
        # Install all tools
        for script in ./install/*.sh; do
            bash "$script"
        done
        # Restore all configs
        restore_configs
        ;;
esac

print_status "Restore completed!"
