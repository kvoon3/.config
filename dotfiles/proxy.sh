export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export all_proxy="${all_proxy:-http://127.0.0.1:7890}"
export no_proxy="${no_proxy:-localhost,127.0.0.1,::1}"
alias proxy='export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 all_proxy=http://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy no_proxy'
