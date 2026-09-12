export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export all_proxy="${all_proxy:-http://127.0.0.1:7890}"
# .ts.net must bypass the local proxy unconditionally: parent processes (herdr/GUI)
# export a stale no_proxy, and a `:-` default would keep it.
case ",${no_proxy:-localhost,127.0.0.1,::1}," in
  *,.ts.net,*) ;;
  *) export no_proxy="${no_proxy:-localhost,127.0.0.1,::1},.ts.net" ;;
esac
alias proxy='export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 all_proxy=http://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy no_proxy'
