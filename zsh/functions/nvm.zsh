# NVM 延迟加载配置
function load_nvm() {
    # 先移除所有别名，防止递归
    unalias node nvm npm npx yarn pnpm 2>/dev/null

    # 加载 NVM
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
        \. "$NVM_DIR/bash_completion"
    else
        print "警告: NVM 未安装或配置不正确"
        return 1
    fi

    # 移除加载函数
    unfunction load_nvm
}

# 创建延迟加载别名
for cmd in node nvm npm npx yarn pnpm; do
    alias $cmd="load_nvm && command $cmd"
done