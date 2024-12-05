# Development Environment Setup

Simple dotfiles management and development environment setup with minimal directory structure.

## Directory Structure
```
.
├── README.md
├── backup.sh
├── restore.sh
├── utils.sh
├── install/
│   ├── core.sh        # Core tools (git, node, python, etc)
│   ├── zsh.sh         # Zsh and terminal setup
│   ├── vscode.sh      # VSCode and extensions
│   ├── iterm.sh       # iTerm2 configuration
│   └── docker.sh      # Docker and docker-compose
└── .config/           # Your actual config files
    ├── vscode/
    ├── zsh/
    ├── git/
    └── iterm/
```

## Usage

### Initial Setup
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
chmod +x *.sh install/*.sh
```

### Backup
```bash
./backup.sh
```

Backs up:
- Shell configuration (Zsh, Oh My Zsh)
- VSCode settings and extensions
- Git configuration
- iTerm2 settings
- Terminal preferences

### Restore
```bash
./restore.sh [options]

Options:
  --all    Install everything (default)
  --core   Install only core tools
  --env    Install only Zsh environment
  --dev    Install only development tools
```

### Individual Tool Installation
```bash
# Install specific tools
./install/core.sh      # Basic development tools
./install/vscode.sh    # VSCode setup
./install/zsh.sh       # Zsh configuration
./install/docker.sh    # Docker installation
```

## Adding New Tools

1. Create installation script in `install/`:
```bash
# install/your-tool.sh
#!/bin/bash
source "../utils.sh"

print_status "Installing your-tool"
# Add installation steps
```

2. Update `restore.sh` to include your tool.

## Customization

- Add your config files directly to `.config/`
- Modify installation scripts in `install/` as needed
- Update `backup.sh` and `restore.sh` for new config files

## License
MIT License