figurine -f "3d.flf" `hostname`

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  zsh-navigation-tools
  zsh-interactive-cd
)

source $ZSH/oh-my-zsh.sh

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

alias l='eza -l --icons --git -a'
alias v=nvim
#alias cd=z
#eval "$(zoxide init zsh)"

#fzf
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#eval "$(fzf --zsh)"

eval "$(starship init zsh)"