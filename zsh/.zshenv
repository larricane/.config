# 基础环境变量设置
typeset -U PATH path  # 确保 PATH 中没有重复项

# XDG Base Directory 规范
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ZSH 相关目录
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export ZSH_DATA_DIR="$XDG_DATA_HOME/zsh"
export ZSH_STATE_DIR="$XDG_STATE_HOME/zsh"

# Eza 配置目录
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"

# Homebrew 配置（在 PATH 设置之前）
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Python 相关配置
export PYENV_ROOT="$HOME/.pyenv"
export POETRY_HOME="$HOME/.poetry"
export POETRY_CONFIG_DIR="$XDG_CONFIG_HOME/poetry"
export POETRY_DATA_DIR="$XDG_DATA_HOME/poetry"
export POETRY_CACHE_DIR="$XDG_CACHE_HOME/poetry"

# nvm 配置
export NVM_DIR="$HOME/.nvm"

# bat 主题设置
export BAT_THEME=tokyonight_night

# 添加以下配置以提高性能
export DISABLE_AUTO_UPDATE=true
export DISABLE_UPDATE_PROMPT=true

# 创建必要的目录
mkdir -p $ZSH_CACHE_DIR $ZSH_DATA_DIR $ZSH_STATE_DIR

# 基础路径设置
path=(
    $PYENV_ROOT/shims
    $PYENV_ROOT/bin
    $HOME/bin
    $HOME/.local/bin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    $path
)

export PATH  # 最后导出 PATH