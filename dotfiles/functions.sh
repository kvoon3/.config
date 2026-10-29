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

# -------------------------------- #
# GitHub shortcuts
#
# `n gh:kvoon3/xxx` opens a repo by name: a checkout already sitting in that
# account's home is reused, otherwise the repo is cloned there first. A path
# after the repo (`n gh:xxx/yyy/src`) is opened inside it, and when the repo is
# not local yet that means "I only want to read this", so it takes a source
# snapshot instead of a clone.
# Full git URLs work too (`n git@github.com:o/r.git`, `n https://...`, any host),
# so a pasted clone URL needs no editing.
# -------------------------------- #

# Prints the home a repo belongs in: my projects, work projects, forks and
# everyone else's on GitHub, and anything off GitHub under ~/repo.
gh-home() {
  case "$1:$2" in
  github.com:kvoon3) printf '%s\n' "$HOME/i" ;;
  github.com:kvoon9) printf '%s\n' "$HOME/vois" ;;
  github.com:*) printf '%s\n' "$HOME/f" ;;
  *) printf '%s\n' "$HOME/repo" ;;
  esac
}

# Prints an existing checkout of owner/repo, or nothing. The homes are flat, so
# the directory name is the repo name and one candidate per home covers it; the
# origin decides, not the directory name.
gh-checkout() {
  local host="$1" owner="$2" repo="$3" dir origin
  for dir in "$HOME/i/$repo" "$HOME/vois/$repo" "$HOME/f/$repo" "$HOME/r/$repo" "$HOME/repo/$repo"; do
    [ -e "$dir/.git" ] || continue
    origin="$(git -C "$dir" config --get remote.origin.url 2>/dev/null)" || continue
    case "$origin" in
    *"$host"[:/]"$owner/$repo" | *"$host"[:/]"$owner/$repo".git)
      printf '%s\n' "$dir"
      return 0
      ;;
    esac
  done
  return 0
}

# Prints a source snapshot of owner/repo, fetching it on first use. The tarball
# is the whole working tree without .git: one request, no history, and the
# neighbouring files that make the code readable are still there. Stays until
# removed, so `rm -rf` is the refresh.
gh-snapshot() {
  local owner="$1" repo="$2"
  local dir="$HOME/.cache/gh-snap/$owner/$repo"
  if [ -d "$dir" ]; then
    printf '%s\n' "$dir"
    return 0
  fi

  # codeload only needs a token for private repos, and gh holds one token per
  # account, so ask for the owner's first and fall back to the active account.
  local token tmp
  token="$(gh auth token -u "$owner" 2>/dev/null || gh auth token 2>/dev/null)"
  tmp="$(mktemp)" || return 1
  if [ -n "$token" ]; then
    curl -fsSL -H "Authorization: token $token" -o "$tmp" \
      "https://codeload.github.com/$owner/$repo/tar.gz/HEAD" || {
      rm -f "$tmp"
      return 1
    }
  else
    curl -fsSL -o "$tmp" "https://codeload.github.com/$owner/$repo/tar.gz/HEAD" || {
      rm -f "$tmp"
      return 1
    }
  fi
  mkdir -p "$dir" || return 1
  if ! tar -xzf "$tmp" -C "$dir" --strip-components=1; then
    rm -rf "$dir" "$tmp"
    return 1
  fi
  rm -f "$tmp"
  printf '%s\n' "$dir"
}

# Prints the repo root and then the path inside it, one per line, cloning or
# snapshotting as needed. Takes `gh:owner/repo`, a bare `owner/repo`, or any full
# git URL (https://, ssh://, git@host:owner/repo), so a pasted clone URL works
# as it is, and a pasted browser URL keeps its file path.
gh-resolve() {
  local spec="$1" url='' host='github.com'
  case "$spec" in
  gh:*) spec="${spec#gh:}" ;;
  *://*)
    # scheme://[user@]host[:port]/owner/repo
    url="$spec"
    spec="${spec#*://}"
    host="${spec%%/*}"
    spec="${spec#*/}"
    ;;
  *@*:*)
    # scp form: [user@]host:owner/repo
    url="$spec"
    spec="${spec#*@}"
    host="${spec%%:*}"
    spec="${spec#*:}"
    ;;
  esac
  host="${host##*@}"
  host="${host%%:*}"
  url="${url%/}"
  # Trailing slash first: `.../bb.git/` would otherwise keep the `.git` and look
  # like a repo named `bb.git`.
  spec="${spec%/}"
  spec="${spec%.git}"
  spec="${spec%/}"

  local owner="${spec%%/*}"
  local rest="${spec#*/}"
  local repo="${rest%%/*}"
  local sub=''
  if [ -z "$repo" ] || [ "$rest" = "$spec" ]; then
    printf 'gh-resolve: expected owner/repo or a git URL, got %s\n' "$1" >&2
    return 1
  fi
  if [ "$rest" != "$repo" ]; then
    sub="${rest#*/}"
    # Browser URLs paste as owner/repo/tree/<ref>/<path>; keep the path only.
    case "$sub" in
    tree/*/* | blob/*/*)
      sub="${sub#*/}"
      sub="${sub#*/}"
      ;;
    tree/* | blob/*) sub='' ;;
    esac
  fi

  local root
  root="$(gh-checkout "$host" "$owner" "$repo")"
  # Snapshots are a GitHub tarball, so any other host falls through to a clone.
  if [ -z "$root" ] && [ -n "$sub" ] && [ "$host" = github.com ]; then
    root="$(gh-snapshot "$owner" "$repo")" || return 1
  fi
  if [ -z "$root" ]; then
    root="$(gh-home "$host" "$owner")/$repo"
    if [ -e "$root" ]; then
      printf 'gh-resolve: %s exists but is not %s\n' "$root" "${url:-$host/$owner/$repo}" >&2
      return 1
    fi
    # git rather than `gh repo clone`: the gh wrapper derives its account from
    # origin, which a fresh clone does not have, so it would run as whichever
    # account is active. git goes through bin/git-credential-github, which reads
    # the account from the owner in the URL.
    #
    # blob:none keeps the commit graph (commit/push/rebase/log all work) and
    # pulls file contents on demand, since a full clone is mostly blobs that
    # never get opened. Servers without partial-clone support just warn and send
    # everything.
    git clone --filter=blob:none "${url:-https://github.com/$owner/$repo.git}" "$root" || return 1
  fi

  printf '%s\n%s\n' "$root" "$sub"
}

# Splits a gh-resolve result into `root` and `sub` in the calling function; sub
# is empty when the spec carries no path.
gh-split() {
  root="${1%%$'\n'*}"
  if [ "$root" = "$1" ]; then
    sub=''
  else
    sub="${1#*$'\n'}"
  fi
}

# Opens nvim in the current directory, on a path, or on a `gh:` spec.
n() {
  if [ $# -eq 0 ]; then
    nvim .
    return
  fi
  case "$1" in
  gh:* | *://* | *@*:*)
    local out root sub
    out="$(gh-resolve "$1")" || return 1
    gh-split "$out"
    # Open from the repo root and stay there, like clone() does, so :lg, LSP
    # roots and relative paths all agree with the checkout.
    cd "$root" || return 1
    if [ -n "$sub" ]; then
      nvim "$sub"
    else
      nvim .
    fi
    ;;
  *) nvim "$@" ;;
  esac
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
    bunx live-server dist
  else
    bunx live-server "$1"
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
