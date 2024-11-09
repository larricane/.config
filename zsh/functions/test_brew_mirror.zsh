function test_brew_mirror() {
    local start_time
    local end_time
    local duration
    local test_commands=(
        "brew update"
        "brew search wget"
        "brew outdated"
    )
    
    echo "开始测试 Homebrew 镜像源速度..."
    echo "----------------------------------------"
    
    # 测试各个镜像源
    for mirror in "default" ${(k)MIRROR_URLS}; do
        echo "测试 $mirror 镜像源:"
        
        # 切换镜像
        if [[ $mirror == "default" ]]; then
            switch_brew_mirror 0
        else
            switch_brew_mirror $mirror
        fi
        
        # 测试多个命令
        for cmd in $test_commands; do
            echo -n "  $cmd: "
            start_time=$(($(gdate +%s%N)/1000000))
            eval "$cmd &>/dev/null"
            end_time=$(($(gdate +%s%N)/1000000))
            duration=$(((end_time - start_time)))
            echo "${duration}ms"
        done
        echo "----------------------------------------"
    done
    
    # 测试镜像连接状态
    echo "\n镜像源连接状态:"
    for mirror in ${(k)MIRROR_URLS}; do
        local api_domain=$(echo "${MIRROR_URLS[$mirror]}" | grep "HOMEBREW_API_DOMAIN" | cut -d'=' -f2)
        local bottle_domain=$(echo "${MIRROR_URLS[$mirror]}" | grep "HOMEBREW_BOTTLE_DOMAIN" | cut -d'=' -f2)
        
        echo "$mirror:"
        echo -n "  API: "
        curl -sI "$api_domain" -m 5 2>/dev/null | head -n 1 || echo "连接失败"
        echo -n "  Bottles: "
        curl -sI "$bottle_domain" -m 5 2>/dev/null | head -n 1 || echo "连接失败"
    done
    
    echo "\n测试完成！"
} 