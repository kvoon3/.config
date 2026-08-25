# ~/.bashrc — dispatcher (mise links here on all OS)
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* || "$OSTYPE" == win32* ]] || [[ "$(uname -s 2>/dev/null)" == MINGW* ]]; then
  [ -f "$HOME/.config/dotfiles/.bashrc.win" ] && source "$HOME/.config/dotfiles/.bashrc.win"
else
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  command -v mise >/dev/null && eval "$(mise activate bash)"
fi
