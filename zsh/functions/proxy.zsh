# 代理设置函数
proxy_on() {
  export http_proxy="http://127.0.0.1:5353"
  export https_proxy="http://127.0.0.1:5353"
  export all_proxy="socks5://127.0.0.1:5353"
  echo "HTTP、HTTPS 和 SOCKS5 代理已开启"
}

proxy_off() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
  echo "所有代理已关闭"
} 