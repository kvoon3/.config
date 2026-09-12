_proxy_url="${PROXY_URL:-http://127.0.0.1:7890}"

# Always rewritten, never `${no_proxy:-...}`: parent processes (herdr/GUI) export a
# stale no_proxy that a `:-` default would preserve. Lowercase wins over uppercase
# in undici and curl, so it is the only key that needs setting.
# .ts.net must bypass the proxy: Clash's resolver cannot resolve MagicDNS names, so
# it falls through to a remote node and resets the TLS handshake.
no_proxy=localhost,127.0.0.1,::1,.ts.net

export http_proxy="${http_proxy:-$_proxy_url}"
export https_proxy="${https_proxy:-$_proxy_url}"
export all_proxy="${all_proxy:-$_proxy_url}"
export no_proxy

proxy() {
  export http_proxy="$_proxy_url" https_proxy="$_proxy_url" all_proxy="$_proxy_url" no_proxy
}

# Keeps no_proxy: it is harmless without a proxy, and dropping it would silently
# drop the .ts.net bypass on the next `proxy`.
unproxy() {
  unset http_proxy https_proxy all_proxy
}
