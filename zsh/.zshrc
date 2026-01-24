# --- 插件配置和加载 ---
# Powerlevel10k 配置
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
POWERLEVEL9K_CONFIG_FILE="${ZDOTDIR}/plugins/.p10k.zsh"

# Powerlevel10k 即时提示
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 定义所有插件
local plugins=(
    /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    # 本地插件配置
    ${ZDOTDIR}/plugins/.p10k.zsh
    ${ZDOTDIR}/plugins/.zoxide.zsh
)

# 统一加载所有插件
for plugin in $plugins; do
    if [[ -f $plugin ]]; then
        source $plugin
    else
        echo "警告: 插件 $plugin 不存在"
    fi
done

# --- 基础配置 ---
# 补全系统设置
autoload -Uz compinit
if [[ -n ${ZSH_CACHE_DIR}/zcompdump(#qN.mh+24) ]]; then
    compinit -d "$ZSH_CACHE_DIR/zcompdump"
else
    compinit -C -d "$ZSH_CACHE_DIR/zcompdump"
fi
_comp_options+=(globdots)

# 历史记录设置
HISTFILE="${ZSH_STATE_DIR}/history"
SAVEHIST=10000
HISTSIZE=9999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt hist_ignore_space

# --- 按键绑定 ---
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# 加载自定义函数
for func in ${ZDOTDIR}/functions/*.zsh; do
    source $func
done

# 加载配置文件
for conf in ${ZDOTDIR}/conf.d/*.zsh; do
    source $conf
done

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/plugins/.p10k.zsh.
[[ ! -f ~/.config/zsh/plugins/.p10k.zsh ]] || source ~/.config/zsh/plugins/.p10k.zsh
