#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Function to print info
print_info() {
    echo -e "${BLUE}--- $1 ---${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}--- $1 ---${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}!!! $1 !!!${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt for confirmation
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

# Setup Xcode Command Line Tools
setup_xcode_cli() {
    print_status "Setting up Xcode Command Line Tools"
    
    if xcode-select -p &>/dev/null; then
        print_info "Xcode Command Line Tools already installed"
    else
        print_info "Installing Xcode Command Line Tools"
        xcode-select --install
        
        # Wait for Xcode CLI tools to be installed
        until xcode-select -p &>/dev/null; do
            sleep 5
            print_info "Waiting for Xcode Command Line Tools installation to complete..."
        done
    fi
}

# Setup Homebrew
setup_homebrew() {
    print_status "Setting up Homebrew"
    
    if command_exists brew; then
        print_info "Homebrew already installed"
        print_info "Updating Homebrew"
        brew update
    else
        print_info "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ $(uname -m) == "arm64" ]]; then
            print_info "Setting up Homebrew for Apple Silicon"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            print_info "Setting up Homebrew for Intel Mac"
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # Install packages from Brewfile
    print_info "Installing packages from Brewfile"
    brew bundle --file="$(pwd)/brew/Brewfile"
}

# Setup Oh My Zsh
setup_oh_my_zsh() {
    print_status "Setting up Oh My Zsh"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_info "Oh My Zsh already installed"
    else
        print_info "Installing Oh My Zsh"
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Setup p10k theme
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_info "Installing Powerlevel10k theme"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
    
    # Setup Zsh plugins
    plugins=(zsh-autosuggestions zsh-syntax-highlighting)
    for plugin in "${plugins[@]}"; do
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]; then
            print_info "Installing $plugin"
            git clone --depth=1 https://github.com/zsh-users/$plugin.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin
        fi
    done
    
    # Link Zsh configuration files
    symlink_config "$(pwd)/configs/zsh/.zshrc" "$HOME/.zshrc"
    symlink_config "$(pwd)/configs/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
}

# Setup Git configuration
setup_git() {
    print_status "Setting up Git configuration"
    
    symlink_config "$(pwd)/configs/git/.gitconfig" "$HOME/.gitconfig"
    
    # Set up Git username and email if not already configured
    if ! git config --global user.name >/dev/null 2>&1; then
        read -p "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi
}

# Setup GPG for Git signing
setup_gpg() {
    print_status "Setting up GPG for commit signing"
    
    # Create GPG configuration directory
    gpg_dir="$HOME/.gnupg"
    mkdir -p "$gpg_dir"
    chmod 700 "$gpg_dir"
    
    # Configure pinentry-mac
    echo "pinentry-program /usr/local/bin/pinentry-mac" > "$gpg_dir/gpg-agent.conf"
    
    # Import GPG key if exists
    gpg_key="$(pwd)/gpg/gpg-key.asc"
    if [ -f "$gpg_key" ]; then
        print_info "Importing GPG key"
        gpg --import "$gpg_key"
        
        # Get the key ID
        key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2)
        
        if [ -n "$key_id" ]; then
            print_info "Setting Git to use GPG key: $key_id"
            git config --global user.signingkey "$key_id"
            git config --global commit.gpgsign true
            
            # Configure GPG to use the right tty
            echo 'export GPG_TTY=$(tty)' >> "$HOME/.zshrc"
        else
            print_warning "Could not determine GPG key ID"
        fi
    else
        print_warning "No GPG key found at $gpg_key"
        print_info "You can generate a GPG key with 'gpg --full-generate-key'"
        print_info "Then export it with 'gpg --export-secret-keys --armor YOUR_KEY_ID > gpg/gpg-key.asc'"
    fi
}

# Setup VS Code
setup_vscode() {
    print_status "Setting up VS Code"
    
    if ! command_exists code; then
        print_warning "VS Code not found. Please install VS Code first."
        return 1
    fi
    
    # Link VSCode settings
    vscode_dir="$HOME/Library/Application Support/Code/User"
    mkdir -p "$vscode_dir"
    
    symlink_config "$(pwd)/vscode/settings.json" "$vscode_dir/settings.json"
    symlink_config "$(pwd)/vscode/keybindings.json" "$vscode_dir/keybindings.json"
    
    # Install VS Code extensions
    if [ -f "$(pwd)/vscode/extensions.txt" ]; then
        print_info "Installing VS Code extensions"
        while IFS= read -r extension; do
            if [ -n "$extension" ] && [[ ! "$extension" =~ ^# ]]; then
                print_info "Installing extension: $extension"
                code --install-extension "$extension" --force
            fi
        done < "$(pwd)/vscode/extensions.txt"
    fi
}

# Setup Kubernetes tools
setup_kubernetes() {
    print_status "Setting up Kubernetes tools"
    
    if ! command_exists kubectl; then
        print_warning "kubectl not found. Please install kubectl first (should be in the Brewfile)."
        return 1
    fi
    
    # Install krew (kubectl plugin manager)
    if ! kubectl krew &>/dev/null; then
        print_info "Installing kubectl krew plugin manager"
        (
            set -x; cd "$(mktemp -d)" &&
            OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
            ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
            KREW="krew-${OS}_${ARCH}" &&
            curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
            tar zxvf "${KREW}.tar.gz" &&
            ./"${KREW}" install krew
        )
    fi
    
    # Install useful krew plugins
    if kubectl krew &>/dev/null; then
        print_info "Installing krew plugins"
        kubectl_plugins=(
            "ctx"
            "ns"
            "neat"
            "access-matrix"
            "view-secret"
            "tree"
        )
        
        for plugin in "${kubectl_plugins[@]}"; do
            if ! kubectl krew list | grep -q "^$plugin$"; then
                print_info "Installing kubectl plugin: $plugin"
                kubectl krew install "$plugin"
            fi
        done
    fi
    
    # Generate kubectl completion
    print_info "Generating kubectl completion for zsh"
    kubectl completion zsh > "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/completions/_kubectl" 2>/dev/null
}

# Setup Go development environment with enhanced tooling
setup_go() {
    print_status "Setting up Go development environment"
    
    if ! command_exists go; then
        print_warning "Go not found. Please install Go first."
        return 1
    fi
    
    # Set GOPATH if not already set
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
    
    # Create necessary Go directories
    mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"
    
    # Install Go tools
    go_tools=(
        "golang.org/x/tools/gopls@latest"                      # Language server
        "golang.org/x/tools/cmd/goimports@latest"             # Import formatter
        "github.com/go-delve/delve/cmd/dlv@latest"            # Debugger
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest" # Linter
        "github.com/cosmtrek/air@latest"                      # Live reload
        "github.com/fatih/gomodifytags@latest"                # Modify struct tags
        "github.com/josharian/impl@latest"                    # Generate interface implementations
        "github.com/cweill/gotests/gotests@latest"            # Generate tests
        "github.com/golang/mock/mockgen@latest"               # Generate mocks
        "github.com/rakyll/gotest@latest"                     # Colorized test output
        "github.com/golang-migrate/migrate/v4/cmd/migrate@latest" # Database migrations
    )
    
    for tool in "${go_tools[@]}"; do
        print_info "Installing Go tool: $tool"
        go install "$tool"
    done
    
    # Create .golangci.yml configuration file in the home directory if it doesn't exist
    if [ ! -f "$HOME/.golangci.yml" ]; then
        print_info "Creating golangci-lint configuration"
        cat > "$HOME/.golangci.yml" << 'EOF'
run:
  timeout: 5m

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - typecheck
    - unused
    - gosec
    - gofmt
    - goimports
    - misspell
    - revive

linters-settings:
  goimports:
    local-prefixes: github.com/alipsidikp
EOF
    fi
}

# Link all dotfiles
link_dotfiles() {
    print_status "Linking dotfiles"
    
    # List of dotfiles to link from configs directory
    for dir in configs/*; do
        dir_name=$(basename "$dir")
        
        if [ -d "$dir" ]; then
            print_info "Processing $dir_name configs"
            
            # Link all files in the directory
            for file in "$dir"/*; do
                if [ -f "$file" ]; then
                    file_name=$(basename "$file")
                    symlink_config "$file" "$HOME/$file_name"
                fi
            done
        fi
    done
}

# Extra Dependencies section - add your customizations here
setup_extra_dependencies() {
    print_status "Setting up extra dependencies"
    
    # ----------------------------------------------------------------------------------
    # This section is designed for you to add your own customizations.
    # You can add additional Homebrew packages, npm modules, Python packages, etc.
    # ----------------------------------------------------------------------------------
    
    # Example: Install additional NPM packages
    # npm_packages=(
    #   "eslint"
    #   "prettier"
    #   "typescript"
    # )
    # 
    # if command_exists npm; then
    #   for package in "${npm_packages[@]}"; do
    #     print_info "Installing npm package: $package"
    #     npm install -g "$package"
    #   done
    # fi
    
    # Example: Install Python packages
    # python_packages=(
    #   "pandas"
    #   "requests"
    #   "flask"
    # )
    # 
    # if command_exists pip3; then
    #   for package in "${python_packages[@]}"; do
    #     print_info "Installing Python package: $package"
    #     pip3 install --user "$package"
    #   done
    # fi
    
    # Example: Install additional VS Code extensions
    # vscode_extensions=(
    #   "ms-python.python"
    #   "vscjava.vscode-java-pack"
    # )
    # 
    # if command_exists code; then
    #   for extension in "${vscode_extensions[@]}"; do
    #     print_info "Installing VS Code extension: $extension"
    #     code --install-extension "$extension" --force
    #   done
    # fi
}

# Set zsh as default shell
setup_zsh_shell() {
    print_status "Setting zsh as default shell"
    
    # Check if zsh is already the default shell
    if [[ "$SHELL" == *zsh ]]; then
        print_info "zsh is already the default shell"
        return 0
    fi
    
    # Check if zsh is installed
    if ! command_exists zsh; then
        print_warning "zsh not found. Installing via Homebrew..."
        brew install zsh
    fi
    
    # Get zsh path
    ZSH_PATH=$(which zsh)
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        print_info "Adding $ZSH_PATH to /etc/shells"
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Change default shell
    print_info "Changing default shell to zsh"
    chsh -s "$ZSH_PATH"
}

# Setup direnv for directory-specific environment variables
setup_direnv() {
    print_status "Setting up direnv"
    
    if ! command_exists direnv; then
        print_info "Installing direnv"
        brew install direnv
    fi
    
    # Add direnv hook to zshrc if not already present
    if ! grep -q "direnv hook zsh" "$HOME/.zshrc"; then
        print_info "Adding direnv hook to zshrc"
        echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
    fi
    
    # Create a global .envrc allowlist
    mkdir -p "$HOME/.config/direnv"
    touch "$HOME/.config/direnv/direnv.toml"
}

# Setup NVM for Node.js version management
setup_nvm() {
    print_status "Setting up NVM (Node Version Manager)"
    
    NVM_DIR="$HOME/.nvm"
    
    if [ -d "$NVM_DIR" ]; then
        print_info "NVM already installed"
    else
        print_info "Installing NVM"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        
        # Load NVM for the current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Install latest LTS version of Node.js
    if command_exists nvm; then
        print_info "Installing latest LTS version of Node.js"
        nvm install --lts
        nvm use --lts
        
        # Install common global npm packages
        npm_packages=(
            "yarn"
            "typescript"
            "ts-node"
            "nodemon"
        )
        
        for package in "${npm_packages[@]}"; do
            print_info "Installing npm package: $package"
            npm install -g "$package"
        done
    fi
}

# Creates helpful aliases and functions
setup_aliases() {
    print_status "Setting up helpful aliases and functions"
    
    # Check if .zshrc.local exists, create if not
    if [ ! -f "$HOME/.zshrc.local" ]; then
        print_info "Creating .zshrc.local file for custom configurations"
        cat > "$HOME/.zshrc.local" << 'EOF'
# Local customizations and overrides for .zshrc

# Example aliases
alias zshconfig="$EDITOR ~/.zshrc"
alias localconfig="$EDITOR ~/.zshrc.local"
alias brewup="brew update && brew upgrade && brew cleanup"

# Git shortcuts
alias gs="git status"
alias gp="git pull"
alias gco="git checkout"
alias gcb="git checkout -b"

# Development shortcuts
alias dc="docker-compose"
alias tf="terraform"

# Add your custom functions below
EOF
    fi
}

# Main script execution
print_status "Starting macOS development environment setup"

# Verify we're on macOS
if [ "$(uname)" != "Darwin" ]; then
    print_error "This script is only for macOS"
    exit 1
fi

# Run all setup functions
setup_xcode_cli
setup_homebrew
setup_zsh_shell
setup_oh_my_zsh
setup_git
setup_gpg
setup_vscode
setup_go
setup_kubernetes
setup_direnv
setup_nvm
setup_aliases
link_dotfiles
setup_extra_dependencies

print_status "Setup completed!"
print_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
print_info "If you encounter any issues, check the README.md for troubleshooting tips"