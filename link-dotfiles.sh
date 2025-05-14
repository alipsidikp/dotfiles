#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Helper functions from utils.sh
print_status() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_info() {
    echo -e "${BLUE}--- $1 ---${NC}"
}

print_warning() {
    echo -e "${YELLOW}--- $1 ---${NC}"
}

print_error() {
    echo -e "${RED}!!! $1 !!!${NC}"
}

confirm() {
    read -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to safely symlink config files
symlink_config() {
    source="$1"
    dest="$2"
    
    if [ -f "$dest" ] || [ -d "$dest" ]; then
        if [ -L "$dest" ]; then
            # It's already a symlink, check if it points to our file
            if [ "$(readlink "$dest")" = "$source" ]; then
                print_info "Symlink already exists and is correct: $dest"
                return 0
            else
                print_warning "Symlink exists but points elsewhere: $dest"
            fi
        else
            print_warning "File exists but is not a symlink: $dest"
            if confirm "Backup existing file and create symlink?"; then
                backup_file="$dest.backup.$(date +%Y%m%d%H%M%S)"
                print_info "Backing up to $backup_file"
                mv "$dest" "$backup_file"
            else
                print_info "Skipping $dest"
                return 0
            fi
        fi
    fi
    
    # Create parent directory if it doesn't exist
    parent_dir=$(dirname "$dest")
    if [ ! -d "$parent_dir" ]; then
        print_info "Creating directory: $parent_dir"
        mkdir -p "$parent_dir"
    fi
    
    print_info "Creating symlink: $dest -> $source"
    ln -sf "$source" "$dest"
}

# Main function to link all dotfiles
link_dotfiles() {
    print_status "Linking dotfiles"
    
    # Zsh configuration
    symlink_config "$(pwd)/configs/zsh/.zshrc" "$HOME/.zshrc"
    symlink_config "$(pwd)/configs/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    
    # Git configuration
    symlink_config "$(pwd)/configs/git/.gitconfig" "$HOME/.gitconfig"
    
    # VSCode configuration
    vscode_dir="$HOME/Library/Application Support/Code/User"
    mkdir -p "$vscode_dir"
    symlink_config "$(pwd)/vscode/settings.json" "$vscode_dir/settings.json"
    symlink_config "$(pwd)/vscode/keybindings.json" "$vscode_dir/keybindings.json"
    
    # Additional config files
    for dir in configs/*; do
        if [ -d "$dir" ]; then
            dir_name=$(basename "$dir")
            if [[ "$dir_name" != "zsh" && "$dir_name" != "git" ]]; then
                print_info "Processing $dir_name configs"
                for file in "$dir"/*; do
                    if [ -f "$file" ]; then
                        file_name=$(basename "$file")
                        symlink_config "$file" "$HOME/$file_name"
                    fi
                done
            fi
        fi
    done
}

# Run the main function
link_dotfiles
print_status "Dotfiles linking completed!"
print_info "You may need to restart your terminal or run 'source ~/.zshrc' to apply changes" 