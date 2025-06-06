# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	docker
	macos
	kubectl
	golang
	brew
	zsh-autosuggestions
	zsh-syntax-highlighting
	history
	extract
	nvm
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# PATH Configuration
# Ensure paths are only added once
typeset -U path

# Homebrew paths - automatically detects Intel vs Apple Silicon
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Go settings
export GOPATH="$HOME/go"
export GOROOT="$(brew --prefix golang)/libexec"
path+=("$GOPATH/bin" "$GOROOT/bin")

# Python settings - prefer user installation
export PYTHONUSERBASE="$HOME/.local"
path+=("$PYTHONUSERBASE/bin")

# Node.js/npm global packages
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
path+=("$NPM_CONFIG_PREFIX/bin")

# Krew (kubectl plugin manager)
export KREW_ROOT="$HOME/.krew"
path+=("$KREW_ROOT/bin")

# Local bin directory for user scripts
path+=("$HOME/.local/bin")

# Export updated PATH
export PATH

# GPG settings for Git commit signing
export GPG_TTY=$(tty)

# Homebrew command not found helper
HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
if [ -f "$HB_CNF_HANDLER" ]; then
  source "$HB_CNF_HANDLER"
fi

# Aliases
alias k="kubectl"
alias g="git"
alias ll="ls -la"
alias reload="source ~/.zshrc"
alias dotfiles="cd $HOME/dotfiles"
alias update="brew update && brew upgrade && brew cleanup"
alias ipy="python -m IPython"

# Kubectl aliases and functions
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
  alias kctx="kubectl config use-context"
  alias kns="kubectl config set-context --current --namespace"
  alias kgp="kubectl get pods"
  alias kgs="kubectl get services"
  alias kgd="kubectl get deployments"
  
  # Function to get pods in namespace
  kpods() {
    kubectl get pods -n "${1:-default}"
  }
  
  # Function to describe pod
  kdesc() {
    kubectl describe pod "$1" "${2:+-n $2}"
  }
fi

# Go dev shortcuts
if command -v go &> /dev/null; then
  alias gotidy="go mod tidy"
  alias gotest="go test ./..."
  alias gobuild="go build"
  alias gorun="go run ."
fi

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Direnv integration - auto load .envrc files
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# NVM (Node Version Manager) configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load local customizations if they exist
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
