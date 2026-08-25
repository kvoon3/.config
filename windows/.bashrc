# windows/.bashrc — Git for Windows bash (C:/Program Files/Git/bin/bash.exe)
# Source: ~/.config/windows/.bashrc → symlinked to ~/.bashrc on Windows
# https://github.com/antfu/dotfiles/blob/main/.zshrc

# Ensure .bash_profile is loaded even for non-login shells (e.g., herdr)
if [ -z "$BASH_PROFILE_SOURCED" ] && [ -f ~/.bash_profile ]; then
  export BASH_PROFILE_SOURCED=1
  source ~/.bash_profile
fi

# Auto completion
# https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
source ~/.git-completion.bash
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
source ~/.git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
# PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'

export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=http://127.0.0.1:7890

# FIXME:
#  - Cursor(VSCode wrapper), it redirects code.cmd to cursor.cmd
#  - But Somehow `cursor` and `code` command is not work in the PATH
# alias code='code.cmd'
# alias cursor='cursor.cmd'

# Basic
alias bashconfig='nvim ~/.config/windows/.bashrc'
alias bashconfig-win='nvim ~/.config/windows/.bashrc'
alias vscodevimrc='code C://Users/admin/i/vscode-vimrc/.vimrc'
alias obconfig='code C://Users/admin/iCloudDrive/iCloud~md~obsidian/KevinNotes/.obsidian.vimrc'
alias alconfig='code C://Users/admin/AppData/Roaming/alacritty/alacritty.toml'
alias nvimconfig='nvim ~/appdata/local/nvim'
alias im-select='C://im-select/im-select-imm'
alias al='alacritty'
alias cc='claude'

# Cat with syntax highlighting
# https://pygments.org/
# alias cat="pygmentize -g"
# https://shiki.style/packages/cli
# all available alias: skat shiki @shikijs/cli
alias sk='skat' # default args: --theme=vitesse-dark --lang=(auto infer)

alias cl='clear'
alias ll='ls -laht'
alias l='ls -lC'

# cd
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

# use path to ignore folder
# alias tree="find . -path '*/node_modules/*' -prune -o -path '*/.git/*' -prune -o -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
# use name to ignore folder
alias tree="find . \( -name 'node_modules' -o -name '.git' \) -prune -o -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

alias scripts="cat package.json | jq '.scripts'" # Need make sure jq already installed(e.g. `scoop install jq`)
alias ss="scripts"

# antfu/ni
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
alias g="nr generate"
alias gz="nr generate:zip"

# Lazy Git
alias lg="lazygit"

# Use github/hub
# alias git=hub

alias gi="git init"

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'
alias origin="git remote get-url origin"

alias gs='git status'
alias gss='git status --short'
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

alias gl='git log'
alias glog='git log --oneline --graph'
alias glogf='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n"'

alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

alias ga='git add'
alias gap='git add --patch'
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

function yz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function glp() {
  git --no-pager log -$1
}

function gd() {
  if [[ -z $1 ]]; then
    git diff --color | diff-so-fancy
  else
    git diff --color $1 | diff-so-fancy
  fi
}

function gdc() {
  if [[ -z $1 ]]; then
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


function weila() {
  cd ~/weila/$1
}

function i() {
  cd ~/i/$1
}

function repros() {
  cd ~/r/$1
}

function forks() {
  cd ~/f/$1
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
  if [[ -z $2 ]]; then
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

function codei() {
  i && code "$@" && cd -
}

function serve() {
  if [[ -z $1 ]]; then
    live-server dist
  else
    live-server $1
  fi
}

# https://starship.rs
eval "$(starship init bash)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export XDG_CONFIG_HOME="$HOME/.config"

# mise — shims only for Git Bash (msys). 'mise activate' emits Windows-style PATH (C:\...;...) which corrupts $PATH on msys (splits on ':'), so skip hook on msys/cygwin.
export PATH="$HOME/.local/share/mise/shims:$PATH"
if [[ "$OSTYPE" != "msys"* ]] && [[ "$OSTYPE" != "cygwin"* ]]; then
  if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
  elif [ -x "$HOME/.local/bin/mise" ]; then
    eval "$("$HOME/.local/bin/mise" activate bash)"
  fi
fi

# secrets — keep OPENAI_API_KEY etc. out of repo
[ -f "$HOME/.config/windows/.secrets.bash" ] && source "$HOME/.config/windows/.secrets.bash"
[ -f "$HOME/.config/dotfiles/.secrets.bash" ] && source "$HOME/.config/dotfiles/.secrets.bash"

# shared helpers (pi agents, etc.)
[ -f "$HOME/.config/dotfiles/functions.sh" ] && source "$HOME/.config/dotfiles/functions.sh"
