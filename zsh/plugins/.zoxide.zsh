# zoxide 配置
export _ZO_DATA_DIR="${ZSH_DATA_DIR}/zoxide"
export _ZO_RESOLVE_SYMLINKS=1

# 延迟加载 zoxide
function load_zoxide() {
    unfunction load_zoxide
    eval "$(zoxide init zsh)"
}

# 创建 z 命令的延迟加载别名
alias z="unalias z && load_zoxide && z" 