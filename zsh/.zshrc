# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
export PATH=$PATH:$HOME/.toolbox/bin
eval "$(/opt/homebrew/bin/brew shellenv)"
# Set up mise for runtime management
eval "$(mise activate zsh)"
source /Users/nalorenz/.brazil_completion/zsh_completion
source <(fzf --zsh)
eval "$(atuin init zsh)"
export FPATH="~/eza/completions/zsh:$FPATH"
eval "$(starship init zsh)"
alias cd="z"
alias l="eza -l --icons --git -a"
eval "$(zoxide init zsh)"
alias v=nvim
alias sshc="TERM=xterm-256color ssh"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
