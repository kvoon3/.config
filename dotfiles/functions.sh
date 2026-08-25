# Shared by zsh and bash (pi agents).

if [ -n "$ZSH_VERSION" ]; then
  setopt no_aliases
else
  shopt -u expand_aliases
fi

glc() {
  git log -n "$1" --pretty=format:"%h %s" | pbcopy
}

yz() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

glp() {
  git --no-pager log -"$1"
}

gd() {
  if [ -z "$1" ]; then
    git diff --color | diff-so-fancy
  else
    git diff --color "$1" | diff-so-fancy
  fi
}

gdc() {
  if [ -z "$1" ]; then
    git diff --color --cached | diff-so-fancy
  else
    git diff --color --cached "$1" | diff-so-fancy
  fi
}

# -------------------------------- #
# Directories
#
# I put
# `~/i` for my projects
# `~/f` for forks
# `~/r` for reproductions
# -------------------------------- #

i() {
  cd ~/i/"$1"
}

repros() {
  cd ~/r/"$1"
}

forks() {
  cd ~/f/"$1"
}

notes() {
  cd ~/i/notes/"$1"
}

weila() {
  cd ~/weila/"$1"
}

repo() {
  cd ~/repo/"$1"
}

pr() {
  if [ "$1" = "ls" ]; then
    gh pr list
  else
    gh pr checkout "$1"
  fi
}

dir() {
  mkdir "$1" && cd "$1"
}

clone() {
  if [ -z "$2" ]; then
    gh repo clone "$@" && cd "$(basename "$1" .git)"
  else
    gh repo clone "$@" && cd "$2"
  fi
}

clonei() {
  i && clone "$@" && code . && cd ~2 2>/dev/null || cd -
}

cloner() {
  repros && clone "$@" && code . && cd ~2 2>/dev/null || cd -
}

clonef() {
  forks && clone "$@" && code . && cd ~2 2>/dev/null || cd -
}

codei() {
  i && code "$@" && cd -
}

gcop() {
  local src="$1"
  local dest="$2"

  if [ -z "$src" ] || [ -z "$dest" ]; then
    echo "Usage: git-copy <source-repo-path> <target-dir>"
    return 1
  fi

  if [ -d "$dest" ]; then
    echo "Error: target directory already exists: $dest"
    return 1
  fi

  echo "Creating clean snapshot from: $src"
  echo "Target: $dest"

  mkdir -p "$dest"

  (
    cd "$src" || exit 1
    git archive HEAD | tar -x -C "../$dest"
  )

  cd "$dest" || return 1

  tree .

  git init
  git add .
  git commit -m "init"

  echo "Done: $dest initialized from $src"
}

# -------------------------------- #
# Server / Port Utilities
# -------------------------------- #

serve() {
  if [ -z "$1" ]; then
    live-server dist
  else
    live-server "$1"
  fi
}

kp() {
  kill -9 $(lsof -t -i:"$1")
}

if [ -n "$ZSH_VERSION" ]; then
  setopt aliases
else
  shopt -s expand_aliases
fi
