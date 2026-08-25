# Shared aliases — zsh (macOS) and bash (Windows)
# Sourced by dotfiles/.zshrc and dotfiles/.bashrc.win

# ——— Shell / Navigation ———
alias cl='clear'
alias ll='ls -laht'
alias l='ls -lC'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias tree="find . \( -name 'node_modules' -o -name '.git' \) -prune -o -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias sk='skat'
alias al='alacritty'

# ——— Node / Vite / pnpm ———
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
alias vr="vp run"
alias g="nr generate"
alias gz="nr generate:zip"

# ——— Git ———
alias gs='git status'
alias gss='git status --short'
alias ga='git add'
alias gA='git add -A'
alias gai='git add -i'
alias gap='git add --patch'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git add -A && git commit -m'
alias gcaam='git add -A && git commit --amend'
alias gfrb='git fetch origin && git rebase origin/master'
alias gp='git push'
alias gpf='git push --force'
alias gpft='git push --follow-tags'
alias gpl='git pull --rebase'
alias gst='git stash'
alias grm='git rm'
alias gmv='git mv'
alias gb='git branch'
alias gbd='git branch -d'
alias gco='git checkout'
alias gcob='git checkout -b'
alias grb='git rebase'
alias grbom='git rebase origin/master'
alias grbc='git rebase --continue'
alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'
alias gxn='git clean -dn'
alias gx='git clean -df'
alias gsha='git rev-parse HEAD | pbcopy'
alias ghci='gh run list -L 1'
alias grt='cd "$(git rev-parse --show-toplevel)"'
alias gi='git init'
alias origin="git remote get-url origin"
alias main='git checkout main'
alias lg="lazygit"
alias ggp='git grep'
alias ggpa='git grep -npW'
alias gll='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n"'
