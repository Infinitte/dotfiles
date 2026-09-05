# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
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
alias bb="brazil-build"
alias l="eza -l --icons --git -a"
eval "$(zoxide init zsh)"
alias v=nvim
alias sshc="TERM=xterm-256color ssh"

#bindkey -v
#export KEYTIMEOUT=1

if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval "$(ssh-agent -s -a ~/.ssh/ssh_auth_sock)"
fi
ssh-add --apple-use-keychain ~/.ssh/mio_rsa

# Amazon Q post block. Keep at the bottom of this file.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

# Added by AIM CLI
export PATH="/Users/nalorenz/.aim/mcp-servers:$PATH"

alias estt-agent="/Users/nalorenz/shared/start-estt-agent.sh"

# bun completions
[ -s "/Users/nalorenz/.bun/_bun" ] && source "/Users/nalorenz/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ── SoL VM quick-connect ──────────────────────────────────────────────
# laptop → dev-dsk → bastion SoL (tools.prod.sol-ops...) → ssh-sol.py sol-cor-N
# Uso:  connect_vm1 <site>      p.ej.  connect_vm1 stn1   (sol-cor-1)
#       connect_vm2 <site>             connect_vm2 stn1   (sol-cor-2)
#       connect_sol_vm <site> [1|2]
# Si cambia tu dev-dsk:  export SOL_DEVDSK=dev-dsk-....amazon.com
connect_sol_vm() {
  emulate -L zsh
  local site="${1:l}" vm="${2:-1}"
  local re_site='^[a-z0-9]{3,5}$'
  if [[ -z "$site" ]]; then
    print -u2 "Uso: connect_vm1 <site> [1|2]   (p.ej. connect_vm1 stn1)"; return 1
  fi
  if [[ ! "$site" =~ $re_site ]]; then
    print -u2 "connect_sol_vm: '$site' no parece un WHID (a-z0-9, 3-5 chars)"; return 1
  fi
  if [[ "$vm" != "1" && "$vm" != "2" ]]; then
    print -u2 "connect_sol_vm: vm debe ser 1 o 2 (sol-cor-1 / sol-cor-2)"; return 1
  fi
  local devdsk="${SOL_DEVDSK:-dev-dsk-nalorenz-1a-8ce1df10.eu-west-1.amazon.com}"
  local bastion="tools.prod.sol-ops.net-auto.opstechit.amazon.dev"
  local device="${site}-sol-cor-${vm}"
  print -u2 "→ ${devdsk}"
  print -u2 "  → ${bastion}"
  print -u2 "    → ssh-sol.py --ssh-device ${device}"
  ssh -t "$devdsk" "ssh -t ${bastion} 'zsh -ic \"oob_password --whid ${site}; echo; echo VM ${device}; ssh-sol.py --ssh-device ${device}\"'"
}
connect_vm1() { connect_sol_vm "$1" 1 }
connect_vm2() { connect_sol_vm "$1" 2 }
# ──────────────────────────────────────────────────────────────────────
