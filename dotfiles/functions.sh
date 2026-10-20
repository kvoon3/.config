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

# gh acts as whichever GitHub account it has active, so a kvoon3 repo surprises
# you during a kvoon9 session (403s, commits by the wrong identity). Derive the
# account from origin's owner and hand gh that token instead; git's push path
# does the same through dotfiles/bin/git-credential-github. `gh auth`/`gh config`
# skip the rewrite so switching accounts still works, and an explicit GH_TOKEN
# wins over the derivation.
gh() {
  if [ -n "$GH_TOKEN" ]; then
    command gh "$@"
    return $?
  fi

  case "$1" in
  auth | config)
    command gh "$@"
    return $?
    ;;
  esac

  local url account token
  url="$(command git config --get remote.origin.url 2>/dev/null)" || url=''
  case "$url" in
  *github.com[:/]kvoon3/*) account=kvoon3 ;;
  *github.com[:/]kvoon9/*) account=kvoon9 ;;
  *) account='' ;;
  esac

  if [ -n "$account" ] && token="$(command gh auth token -u "$account" 2>/dev/null)" && [ -n "$token" ]; then
    GH_TOKEN="$token" command gh "$@"
    return $?
  fi

  command gh "$@"
}

# hunkdiff. `hunk gh …` only reads GH_TOKEN/GITHUB_TOKEN (it ignores gh's
# own auth config), so borrow the token `gh` already holds.
hunk() {
  if [ "$1" = "gh" ] && [ -z "$GH_TOKEN" ] && [ -z "$GITHUB_TOKEN" ]; then
    local token
    token="$(command gh auth token 2>/dev/null)"
    if [ -n "$token" ]; then
      GH_TOKEN="$token" command hunk "$@"
      return $?
    fi
    printf 'hunk: no GH_TOKEN and `gh auth token` failed; run `gh auth login`\n' >&2
  fi
  command hunk "$@"
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
