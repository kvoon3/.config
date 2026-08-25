export HTTP_PROXY="${HTTP_PROXY:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export ALL_PROXY="${ALL_PROXY:-http://127.0.0.1:7890}"
export all_proxy="${all_proxy:-http://127.0.0.1:7890}"
export NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,::1}"
export no_proxy="$NO_PROXY"
alias proxy='export HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 ALL_PROXY=http://127.0.0.1:7890 all_proxy=http://127.0.0.1:7890'
alias unproxy='unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy NO_PROXY no_proxy'
