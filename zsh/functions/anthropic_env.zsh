# ~/anthropic_env.zsh

# .env 文件位置（你也可以改成某个项目目录下的 .env）
: ${ANTHROPIC_ENV_FILE:="$HOME/.config/zsh/anthropic.env"}

# 存储已加载的变量名，用于 anthropic_off 时 unset
_anthropic_loaded_vars=()

# 安全加载：只接受 KEY=VALUE 这种行，忽略空行/注释
_anthropic_load_env() {
  local f="$1"
  [[ -f "$f" ]] || { echo "[anthropic] env file not found: $f"; return 1; }

  local line key val
  _anthropic_loaded_vars=()  # 重置列表
  while IFS= read -r line || [[ -n "$line" ]]; do
    # 去掉首尾空白
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    # 跳过空行/注释
    [[ -z "$line" || "$line" == \#* ]] && continue
    # 必须包含等号
    [[ "$line" != *"="* ]] && continue

    key="${line%%=*}"
    val="${line#*=}"

    # key 再 trim 一下
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"

    # 去掉 val 两侧引号（可选）
    if [[ "$val" == \"*\" && "$val" == *\" ]]; then
      val="${val:1:-1}"
    elif [[ "$val" == \'*\' && "$val" == *\' ]]; then
      val="${val:1:-1}"
    fi

    export "$key=$val"
    _anthropic_loaded_vars+=("$key")
  done < "$f"
}

anthropic_on() {
  if [[ ! -f "$ANTHROPIC_ENV_FILE" ]]; then
    echo "[anthropic] env file not found: $ANTHROPIC_ENV_FILE"
    echo "[anthropic] Please create it with your API settings, e.g.:"
    echo "  mkdir -p \"\$(dirname \"$ANTHROPIC_ENV_FILE\")\""
    echo "  echo 'ANTHROPIC_AUTH_TOKEN=your_token_here' > \"$ANTHROPIC_ENV_FILE\""
    echo "  chmod 600 \"$ANTHROPIC_ENV_FILE\""
    return 1
  fi
  _anthropic_load_env "$ANTHROPIC_ENV_FILE" || return 1
  echo "[anthropic] ON (loaded: $ANTHROPIC_ENV_FILE)"
  anthropic_status
}

anthropic_off() {
  for var in "${_anthropic_loaded_vars[@]}"; do
    unset "$var"
  done
  _anthropic_loaded_vars=()
  echo "[anthropic] OFF"
}

anthropic_status() {
  if [[ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
    echo "[anthropic] ANTHROPIC_AUTH_TOKEN: SET (hidden)"
  else
    echo "[anthropic] ANTHROPIC_AUTH_TOKEN: NOT SET"
  fi
  echo "[anthropic] ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL:-NOT SET}"
}

# 可选：快速打开编辑
anthropic_edit() {
  ${EDITOR:-vim} "$ANTHROPIC_ENV_FILE"
}