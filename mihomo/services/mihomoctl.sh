#!/usr/bin/env bash
set -euo pipefail

CORE="/opt/mihomo/bin/mihomo-core"
CONF_DIR="/opt/mihomo/config"
CONF_FILE="${CONF_DIR}/config.yaml"

get_secret() {
  # Read secret from config file
  local sec
  sec=$(grep -E "^[[:space:]]*secret:" "${CONF_FILE}" 2>/dev/null | head -n1 | sed -E "s/^[[:space:]]*secret:[[:space:]]*//" | tr -d "\"\047")
  echo "$sec"
}

get_config_value() {
  local key="$1"
  grep -E "^[[:space:]]*${key}:" "${CONF_FILE}" 2>/dev/null | head -n1 | sed -E "s/^[[:space:]]*${key}:[[:space:]]*//" | tr -d "\"\047"
}

PORT="$(get_config_value mixed-port)"
if [[ -z "${PORT}" ]]; then
  PORT="$(get_config_value port)"
fi
if [[ -z "${PORT}" ]]; then
  PORT="7890"
fi

CTRL_HOST="127.0.0.1"
CTRL_PORT="9090"
CTRL_RAW="$(get_config_value external-controller)"
if [[ -n "${CTRL_RAW}" ]]; then
  if [[ "${CTRL_RAW}" == *":"* ]]; then
    CTRL_HOST="${CTRL_RAW%:*}"
    CTRL_PORT="${CTRL_RAW##*:}"
    if [[ -z "${CTRL_HOST}" ]]; then
      CTRL_HOST="127.0.0.1"
    fi
  else
    CTRL_PORT="${CTRL_RAW}"
  fi
fi

API="http://${CTRL_HOST}:${CTRL_PORT}"

pick_service() {
  # Prefer Wi-Fi if exists, fallback to first service
  local svc
  svc=$(networksetup -listallnetworkservices 2>/dev/null | tail -n +2 | grep -x "Wi-Fi" || true)
  if [[ -n "${svc}" ]]; then
    echo "${svc}"
    return
  fi
  networksetup -listallnetworkservices 2>/dev/null | tail -n +2 | head -n 1
}

SERVICE="${MIHOMO_SERVICE:-$(pick_service)}"

proxy_on() {
  sudo networksetup -setwebproxy "${SERVICE}" 127.0.0.1 "${PORT}"
  sudo networksetup -setsecurewebproxy "${SERVICE}" 127.0.0.1 "${PORT}"
  sudo networksetup -setsocksfirewallproxy "${SERVICE}" 127.0.0.1 "${PORT}"

  sudo networksetup -setwebproxystate "${SERVICE}" on
  sudo networksetup -setsecurewebproxystate "${SERVICE}" on
  sudo networksetup -setsocksfirewallproxystate "${SERVICE}" on

  echo "✅ Proxy ON for: ${SERVICE} -> 127.0.0.1:${PORT}"
}

proxy_off() {
  sudo networksetup -setwebproxystate "${SERVICE}" off
  sudo networksetup -setsecurewebproxystate "${SERVICE}" off
  sudo networksetup -setsocksfirewallproxystate "${SERVICE}" off

  echo "✅ Proxy OFF for: ${SERVICE}"
}

status() {
  echo "== Service: ${SERVICE} =="
  echo "--- HTTP ---"
  networksetup -getwebproxy "${SERVICE}"
  echo "--- HTTPS ---"
  networksetup -getsecurewebproxy "${SERVICE}"
  echo "--- SOCKS ---"
  networksetup -getsocksfirewallproxy "${SERVICE}"
  echo
  echo "== Ports =="
  lsof -iTCP:${PORT} -sTCP:LISTEN || true
  lsof -iTCP:${CTRL_PORT} -sTCP:LISTEN || true
}

reload() {
  local sec
  sec=$(get_secret)
  if [[ -n "${sec}" && "${sec}" != "" ]]; then
    curl -sS -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer ${sec}" -d "{}" "${API}/configs?force=true"
  else
    curl -sS -X PUT -H "Content-Type: application/json" -d "{}" "${API}/configs?force=true"
  fi
  echo
  echo "✅ Reloaded config via API (${API})"
}


restart() {
  echo "♻️ Restarting Mihomo (LaunchDaemon) ..."
  sudo launchctl kickstart -k system/com.enacirral.mihomo || true

  # Wait for ports to be ready
  for i in {1..30}; do
    if lsof -iTCP:${PORT} -sTCP:LISTEN >/dev/null 2>&1 && lsof -iTCP:${CTRL_PORT} -sTCP:LISTEN >/dev/null 2>&1; then
      echo "✅ Mihomo is back (${PORT}/${CTRL_PORT} listening)"
      exit 0
    fi
    sleep 0.2
  done

  echo "⚠️ Restart triggered, but ports not ready yet"
  exit 0
}

case "${1:-}" in
  on) proxy_on ;;
  off) proxy_off ;;
  status) status ;;
  reload) reload ;;
  restart) restart ;;
  *)
    echo "Usage: mihomoctl {on|off|status|reload|restart}"
    exit 1
    ;;
esac
