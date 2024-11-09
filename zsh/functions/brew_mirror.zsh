# Homebrew 镜像配置
declare -A MIRROR_URLS
MIRROR_URLS[aliyun]="
HOMEBREW_INSTALL_FROM_API=1
HOMEBREW_API_DOMAIN=https://mirrors.aliyun.com/homebrew-bottles/api
HOMEBREW_BREW_GIT_REMOTE=https://mirrors.aliyun.com/homebrew/brew.git
HOMEBREW_CORE_GIT_REMOTE=https://mirrors.aliyun.com/homebrew/homebrew-core.git
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
"

MIRROR_URLS[tsinghua]="
HOMEBREW_API_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
HOMEBREW_BREW_GIT_REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
HOMEBREW_CORE_GIT_REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
HOMEBREW_PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
"

MIRROR_URLS[ustc]="
HOMEBREW_BREW_GIT_REMOTE=https://mirrors.ustc.edu.cn/brew.git
HOMEBREW_CORE_GIT_REMOTE=https://mirrors.ustc.edu.cn/homebrew-core.git
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
HOMEBREW_API_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles/api
"

CURRENT_MIRROR="0"

function get_mirror_key() {
    local mirror_param=$1
    [[ $mirror_param == "0" ]] && echo "RESET_MIRROR" && return
    [[ -n ${MIRROR_URLS[$mirror_param]} ]] && echo $mirror_param && return
    [[ ! $mirror_param =~ ^[0-9]+$ ]] && echo "PARAM_ERROR" && return

    local -a sorted_keys=(${(ok)MIRROR_URLS})
    local index=$mirror_param
    ((index > 0 && index <= $#sorted_keys)) && echo $sorted_keys[$index] || echo "PARAM_ERROR"
}

function switch_brew_mirror() {
    local mirror_param=${1:-$CURRENT_MIRROR}
    local mirror_key=$(get_mirror_key $mirror_param)

    case $mirror_key in
        "RESET_MIRROR")
            CURRENT_MIRROR="0"
            unset_brew_mirror
            ;;
        "PARAM_ERROR")
            echo_mirror_usage $mirror_param
            ;;
        *)
            CURRENT_MIRROR=$mirror_key
            export_mirror_to_shell $mirror_key
            ;;
    esac
}

function export_mirror_to_shell() {
    local mirror_key=$1
    local mirror_config=${MIRROR_URLS[$mirror_key]}
    while read -r line; do
        if [[ -n $line ]]; then
            export $line
        fi
    done <<< $mirror_config
    echo "Switched to $mirror_key mirror."
}

function echo_mirror_usage() {
    local param=$1
    local mirror_options="0|${(kj:|:)MIRROR_URLS}"
    echo "Invalid parameter $param. Usage: switch_brew_mirror [$mirror_options]"
}

function unset_brew_mirror() {
    local -a first_mirror=(${MIRROR_URLS[${(k)MIRROR_URLS[1]}]})
    for config in $first_mirror; do
        unset ${config%%=*}
    done
    echo "Using Homebrew default URL."
}

# 在文件末尾添加检查函数
function check_brew_mirror() {
    echo "当前 Homebrew 镜像配置："
    echo "----------------------------------------"
    
    # 检查是否为默认配置
    if [[ $CURRENT_MIRROR == "0" ]]; then
        echo "使用默认源"
        return
    fi
    
    # 检查环境变量
    echo "当前镜像: $CURRENT_MIRROR"
    echo "API Domain: $HOMEBREW_API_DOMAIN"
    echo "Bottle Domain: $HOMEBREW_BOTTLE_DOMAIN"
    echo "Brew Git Remote: $HOMEBREW_BREW_GIT_REMOTE"
    echo "Core Git Remote: $HOMEBREW_CORE_GIT_REMOTE"
    [[ -n $HOMEBREW_INSTALL_FROM_API ]] && echo "Install From API: $HOMEBREW_INSTALL_FROM_API"
    [[ -n $HOMEBREW_PIP_INDEX_URL ]] && echo "PIP Index URL: $HOMEBREW_PIP_INDEX_URL"
}