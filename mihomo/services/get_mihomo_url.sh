TAG="Prerelease-Alpha"
ARCH="$(uname -m)"
[ "$ARCH" = "arm64" ] && PLAT="darwin-arm64" || PLAT="darwin-amd64"

URL="$(
  curl -sL "https://api.github.com/repos/vernesong/mihomo/releases/tags/${TAG}" \
  | jq -r --arg plat "$PLAT" '
      .assets[]
      | select(.name | contains($plat))
      | select(.name | endswith(".gz"))
      | .browser_download_url
    ' \
  | head -n 1
)"

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
  echo "没找到匹配资产：$PLAT *.gz (TAG=$TAG)" >&2
  exit 1
fi

echo "Download URL: $URL"