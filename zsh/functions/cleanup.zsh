# 清理 ZSH 缓存文件
zsh_cleanup() {
    echo "清理 ZSH 缓存..."
    rm -f "$ZSH_CACHE_DIR"/zcompdump*
    rm -f "$ZSH_CACHE_DIR"/*.zwc
    
    echo "重新初始化补全系统..."
    compinit -d "$ZSH_CACHE_DIR/zcompdump"
    
    echo "清理完成！"
} 