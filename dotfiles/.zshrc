export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z)

alias nv="nvim"
alias zshconfig='nvim ~/.zshrc'
alias alconfig='nvim ~/.config/alacritty/alacritty.toml'
alias vimrc='nvim ~/.code.vimrc'
alias obrc='nvim ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/KevinNotes/.obsidian.vimrc'
alias ngc='nvim /opt/homebrew/etc/nginx'
alias nvimconfig='nvim ~/.config/nvim'
alias gitconfig='nvim ~/.config/git'
alias ss='cat package.json | jq ".scripts"'
alias vr="vp run"
alias gcl='gh repo clone'
alias gl='git log --oneline --graph'
alias glp='git log -p'
alias gll='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n"'
alias ggp='git grep'
alias ggpa='git grep -npW'
alias gai='git add -i'

source "$HOME/.config/dotfiles/proxy.sh"
source "$HOME/.config/dotfiles/mirrors.sh"
source "$HOME/.config/dotfiles/aliases.sh"
source "$HOME/.config/dotfiles/functions.sh"

fpath=(/Users/kvoon/.zsh/completions $fpath)
source $ZSH/oh-my-zsh.sh

[ -s "/Users/kvoon/.bun/_bun" ] && source "/Users/kvoon/.bun/_bun"
. "$HOME/.vite-plus/env"
export PNPM_HOME="/Users/kvoon/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(/Users/kvoon/.local/bin/mise activate zsh)"
[ -f ~/.config/dotfiles/.secrets.zsh ] && source ~/.config/dotfiles/.secrets.zsh
