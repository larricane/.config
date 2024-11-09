# 安全操作别名
alias cp='cp -i'   # 复制文件时，如果目标文件存在，会询问是否覆盖
alias mv='mv -i'   # 移动文件时，如果目标文件存在，会询问是否覆盖
alias rm='rm -i'   # 删除文件时会询问确认
alias mkdir='mkdir -p'  # 创建目录时自动创建父目录

# eza 别名
alias ls="eza --icons=always"
alias la="eza -lag --icons"
alias lt="eza -lTg --icons"
alias lt1="eza -lTg --level=1 --icons"
alias lt2="eza -lTg --level=2 --icons"
alias lt3="eza -lTg --level=3 --icons"
alias lta="eza -lTag --icons"
alias lta1="eza -lTag --level=1 --icons"
alias lta2="eza -lTag --level=2 --icons"
alias lta3="eza -lTag --level=3 --icons"

# 目录导航别名
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
