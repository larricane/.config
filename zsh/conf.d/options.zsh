# Shell 选项设置
setopt AUTO_CD             # 可以直接输入目录名切换目录，无需输入 cd
setopt AUTO_PUSHD          # 每次 cd 时自动将前一个目录加入栈
setopt PUSHD_IGNORE_DUPS   # 避免相同的目录多次加入栈
setopt EXTENDED_GLOB       # 启用高级通配符功能，如 ^(pattern) 表示排除匹配
setopt CORRECT             # 命令输错时提供更正建议
setopt COMPLETE_IN_WORD    # 在单词中间也可以补全