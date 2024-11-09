# Python 开发环境延迟加载配置
function load_python_env() {
    # 先移除所有别名，防止递归
    unalias python python3 pip pip3 pyenv poetry pt pti ptu pta ptd ptr pts 2>/dev/null

    # 加载 pyenv
    if command -v pyenv >/dev/null; then
        eval "$(command pyenv init -)"
        eval "$(command pyenv virtualenv-init -)"
    else
        print "警告: pyenv 未安装"
    fi

    # 加载 poetry
    if command -v poetry >/dev/null; then
        # poetry completions
        fpath+=($POETRY_HOME/completions)
        compinit
    else
        print "警告: poetry 未安装"
    fi

    # 设置 Poetry 别名
    alias pti='poetry install'
    alias ptu='poetry update'
    alias pta='poetry add'
    alias ptd='poetry remove'
    alias ptr='poetry run'
    alias pts='poetry shell'
    alias pt='poetry'
    
    # 移除加载函数
    unfunction load_python_env
}

# 创建延迟加载别名
for cmd in python python3 pip pip3; do
    alias $cmd="load_python_env && command $cmd"
done

# pyenv 和 poetry 的延迟加载
alias pyenv="load_python_env && command pyenv"
alias poetry="load_python_env && command poetry"
alias pt="load_python_env && command poetry"