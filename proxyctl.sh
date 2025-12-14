#!/usr/bin/env sh
# proxyctl.sh — mixed-port–aware proxy controller

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/proxyctl"
CONFIG_FILE="$CONFIG_DIR/config"

_proxy_load() {
  [ -f "$CONFIG_FILE" ] || return 1
  # shellcheck disable=SC1090
  . "$CONFIG_FILE"
}

_has_scheme() {
  case "$1" in
    *://*) return 0 ;;
    *)     return 1 ;;
  esac
}

proxy_set() {
  # Usage:
  #   proxy_set host:port
  #   proxy_set http://host:port
  #   proxy_set http://host:port socks5://host:port

  ARG1="$1"
  ARG2="$2"

  [ -z "$ARG1" ] && {
    echo "Usage: proxy_set <host:port | url> [all_proxy_url]"
    return 1
  }

  mkdir -p "$CONFIG_DIR"

  # Case 1: shorthand host:port (mixed proxy)
  if ! _has_scheme "$ARG1"; then
    HTTP_URL="http://$ARG1"
    ALL_URL="socks5://$ARG1"

  # Case 2: explicit http + optional all
  else
    HTTP_URL="$ARG1"
    ALL_URL="$ARG2"
  fi

  {
    echo "PROXY_HTTP=\"$HTTP_URL\""
    [ -n "$ALL_URL" ] && echo "PROXY_ALL=\"$ALL_URL\""
  } > "$CONFIG_FILE"

  echo "Proxy configuration saved:"
  echo "  http(s): $HTTP_URL"
  echo "  all    : ${ALL_URL:-<same as http>}"
}

proxy_on() {
  if ! _proxy_load; then
    echo "No proxy config found. Run proxy_set first."
    return 1
  fi

  export http_proxy="$PROXY_HTTP"
  export https_proxy="$PROXY_HTTP"
  export all_proxy="${PROXY_ALL:-$PROXY_HTTP}"

  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$https_proxy"
  export ALL_PROXY="$all_proxy"

  export no_proxy="localhost,127.0.0.1,::1"
  export NO_PROXY="$no_proxy"

  echo "Proxy enabled"
}

proxy_off() {
  unset http_proxy https_proxy all_proxy
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
  unset no_proxy NO_PROXY
  echo "Proxy disabled"
}

proxy_show() {
  echo "Status:"
  [ -n "$http_proxy" ] && echo "  Enabled" || echo "  Disabled"

  echo "Config:"
  if [ -f "$CONFIG_FILE" ]; then
    sed 's/^/  /' "$CONFIG_FILE"
  else
    echo "  <not configured>"
  fi
}
