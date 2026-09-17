# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
#
# export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
export PATH="/usr/local/n/versions/node/24.1.0/bin:$PATH"
export EDITOR=vim

alias cdd="/Users/watanabekoji/Desktop"
alias cdf="/Users/watanabekoji/42"
alias rm="trash"
alias p="python"
alias penv="python3 -m venv .venv"
alias apenv="source .venv/bin/activate"
alias dpenv="deactivate"
alias vim="nvim"

alias restart="exec $SHELL -l"
alias deco="~/dotfiles/bin/deco.sh"

repo() {
  # 現在の 'origin' リモートの 'fetch' URLを取得
  REPO_URL=$(git config --get remote.origin.url)

  if [ -z "$REPO_URL" ]; then
    echo "Error: cannnot find remote 'origin'"
    return 1
  fi

  # SSH形式 (git@github.com:user/repo.git) をHTTPS形式に変換
  # 例: git@github.com:jaytakahashii/42_Leaffliction.git -> https://github.com/jaytakahashii/42_Leaffliction
  HTTPS_URL=$(echo "$REPO_URL" | sed -E 's/^git@github.com:/https:\/\/github.com\//;s/\.git$//')

  # HTTPS形式ではないURL (例: https://...) の場合はそのまま使用
  if [[ "$HTTPS_URL" == "$REPO_URL" ]]; then
    OPEN_URL="$REPO_URL"
  else
    OPEN_URL="$HTTPS_URL"
  fi

  echo "open: $OPEN_URL"

  if command -v open >/dev/null 2>&1; then
    open "$OPEN_URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$OPEN_URL"
  elif command -v start >/dev/null 2>&1; then # Windows (Git Bash/CMD)
    start "$OPEN_URL"
  else
    echo "Error: cannot find the command to open('open', 'xdg-open', 'start')。"
    return 1
  fi
}


# apriltag ヘッダーファイルへのパス
export CPLUS_INCLUDE_PATH=/usr/local/include/apriltag:$CPLUS_INCLUDE_PATH
# apriltag ライブラリへのパス
export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
# ライブラリパスexport DYLD_LIBRARY_PATH=/usr/local/lib:$DYLD_LIBRARY_PATH
export PATH=$PATH:~/my-bin/
# apriltag common フォルダへのパス
export CPLUS_INCLUDE_PATH=/usr/local/include/apriltag/common:$CPLUS_INCLUDE_PATH
# OpenCV ヘッダーファイルへのパス
export CPLUS_INCLUDE_PATH=/opt/homebrew/opt/opencv/include/opencv4:$CPLUS_INCLUDE_PATH

alias docker-webserv="docker exec -it webserv-container /bin/bash"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

alias g++="/opt/homebrew/Cellar/gcc/14.2.0_1/bin/g++-14"

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
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/usr/local/opt/llvm/bin:$PATH"

eval "$(mise activate zsh)"

# Check if we are inside the VS Code integrated terminal
if [ "$TERM_PROGRAM" = "vscode" ]; then
    export HISTFILE="$HOME/.zsh_history_vscode"
else
    # This covers iTerm2 and other standard terminals
    export HISTFILE="$HOME/.zsh_history"
fi
export PATH="$HOME/.local/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/watanabekoji/.local/bin:$PATH"
