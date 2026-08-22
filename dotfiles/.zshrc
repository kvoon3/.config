export ZSH="$HOME/.oh-my-zsh"

# alias rm="trash"

# alias rmrf="rm -rf"
alias lg="lazygit"
alias nv="nvim"
alias cc="claude --dangerously-skip-permissions"
alias ccw="claude --dangerously-skip-permissions -w"
alias ccc="claude --dangerously-skip-permissions -c"
alias al="alacritty"

export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export ALL_PROXY=http://127.0.0.1:7890

alias proxy="export {http,https,all}_proxy=http://127.0.0.1:7890"
alias unproxy="unset {http,https,all,no}_proxy"

# git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
ZSH_THEME="spaceship"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
# git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-z
  # zsh-vi-mode
)

# Config file

alias zshconfig='nvim ~/.zshrc'
alias alconfig='nvim ~/.config/alacritty/alacritty.toml'
alias vimrc='nvim ~/.code.vimrc'
alias obrc='nvim ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/KevinNotes/.obsidian.vimrc'
alias ngc='nvim /opt/homebrew/etc/nginx'
alias nvimconfig='nvim ~/.config/nvim'
alias gitconfig='nvim ~/.config/git'

alias ss='cat package.json | jq ".scripts"'

# https://ohmyz.sh/
# opencli completion
fpath=(/Users/kvoon/.zsh/completions $fpath)
source $ZSH/oh-my-zsh.sh

# -------------------------------- #
# Node Package Manager
# -------------------------------- #
# https://github.com/antfu/ni

alias nio="ni --prefer-offline"
alias s="nr start"
alias d="nr dev"
alias dop="nr dev --open"
alias b="nr build"
alias bw="nr build --watch"
alias t="nr test"
alias tu="nr test -u"
alias tw="nr test --watch"
alias w="nr watch"
alias p="nr play"
alias c="nr typecheck"
alias lint="nr lint"
alias lintf="nr lint --fix"
alias release="nr release"
alias re="nr release"

# vite-plus
alias vr="vp run"

# Use github/hub
alias git=hub

alias gi='git init'

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

alias gs='git status'
alias gp='git push'
alias gpf='git push --force'
alias gpft='git push --follow-tags'
alias gpl='git pull --rebase'
alias gcl='git clone'
alias gst='git stash'
alias grm='git rm'
alias gmv='git mv'

alias main='git checkout main'

alias gco='git checkout'
alias gcob='git checkout -b'

alias gb='git branch'
alias gbd='git branch -d'

alias grb='git rebase'
alias grbom='git rebase origin/master'
alias grbc='git rebase --continue'

alias gl='git log --oneline --graph'
alias glp='git log -p'
alias gll='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n"'

alias ggp='git grep'
alias ggpa='git grep -npW'

function glc() {
  git log -n "$1" --pretty=format:"%h %s" | pbcopy
}

alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

alias ga='git add'
alias gai='git add -i'
alias gA='git add -A'

alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git add -A && git commit -m'
alias gcaam='git add -A && git commit --amend'
alias gfrb='git fetch origin && git rebase origin/master'

alias gxn='git clean -dn'
alias gx='git clean -df'

alias gsha='git rev-parse HEAD | pbcopy'

alias ghci='gh run list -L 1'


function glp() {
  git --no-pager log -$1
}

function gd() {
  if [[ -z $1 ]] then
    git diff --color | diff-so-fancy
  else
    git diff --color $1 | diff-so-fancy
  fi
}

function gdc() {
  if [[ -z $1 ]] then
    git diff --color --cached | diff-so-fancy
  else
    git diff --color --cached $1 | diff-so-fancy
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

function i() {
  cd ~/i/$1
}

function repros() {
  cd ~/r/$1
}

function forks() {
  cd ~/f/$1
}

function notes () {
  cd ~/i/notes/$1
}

function weila() {
  cd ~/weila/$1
}

function repo() {
  cd ~/repo/$1
} 

function pr() {
  if [ $1 = "ls" ]; then
    gh pr list
  else
    gh pr checkout $1
  fi
}

function dir() {
  mkdir $1 && cd $1
}

function clone() {
  if [[ -z $2 ]] then
    hub clone "$@" && cd "$(basename "$1" .git)"
  else
    hub clone "$@" && cd "$2"
  fi
}

# Clone to ~/i and cd to it
function clonei() {
  i && clone "$@" && code . && cd ~2
}

function cloner() {
  repros && clone "$@" && code . && cd ~2
}

function clonef() {
  forks && clone "$@" && code . && cd ~2
}

function cloneme() {
  i && clone "https://github.com/kvoon3/$@" && code . && cd ~2
}

function codei() {
  i && code "$@" && cd -
}

function gcop() {
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

function serve() {
  if [[ -z $1 ]] then
    live-server dist
  else
    live-server $1
  fi
}

function kp() {
  kill -9 $(lsof -t -i:$1)
}

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export PATH=$PATH:$HOME/.local/opt/go/bin

# === NPM BINARY CHINA ===
# https://github.com/cnpm/binary-mirror-config/blob/master/package.json#L53
export NODEJS_ORG_MIRROR="https://cdn.npmmirror.com/binaries/node"
export PHANTOMJS_CDNURL="https://cdn.npmmirror.com/binaries/phantomjs"
export CHROMEDRIVER_CDNURL="https://cdn.npmmirror.com/binaries/chromedriver"
export OPERADRIVER_CDNURL="https://cdn.npmmirror.com/binaries/operadriver"
export ELECTRON_MIRROR="https://cdn.npmmirror.com/binaries/electron/"
export ELECTRON_BUILDER_BINARIES_MIRROR="https://cdn.npmmirror.com/binaries/electron-builder-binaries/"
export SASS_BINARY_SITE="https://cdn.npmmirror.com/binaries/node-sass"
export SWC_BINARY_SITE="https://cdn.npmmirror.com/binaries/node-swc"
export NWJS_URLBASE="https://cdn.npmmirror.com/binaries/nwjs/v"
export PUPPETEER_DOWNLOAD_HOST="https://cdn.npmmirror.com/binaries"
export SENTRYCLI_CDNURL="https://cdn.npmmirror.com/binaries/sentry-cli"
export SAUCECTL_INSTALL_BINARY_MIRROR="https://cdn.npmmirror.com/binaries/saucectl"
# For Cypress >=10.6.0, https://docs.cypress.io/guides/references/changelog#10-6-0
export CYPRESS_DOWNLOAD_PATH_TEMPLATE='https://cdn.npmmirror.com/binaries/cypress/${version}/${platform}-${arch}/cypress.zip'
# npm 11 rejects these obsolete package-specific config names.
# export npm_config_sharp_binary_host="https://cdn.npmmirror.com/binaries/sharp"
# export npm_config_sharp_libvips_binary_host="https://cdn.npmmirror.com/binaries/sharp-libvips"
# export npm_config_robotjs_binary_host="https://cdn.npmmirror.com/binaries/robotj"

# bun completions
[ -s "/Users/kvoon/.bun/_bun" ] && source "/Users/kvoon/.bun/_bun"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# pnpm (must come after vite-plus to take precedence)
export PNPM_HOME="/Users/kvoon/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# shims: child processes (e.g. pi bash tools) get mise bins without re-activate
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(/Users/kvoon/.local/bin/mise activate zsh)"

# secrets (untracked)
[ -f ~/.config/dotfiles/.secrets.zsh ] && source ~/.config/dotfiles/.secrets.zsh
