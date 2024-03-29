# shellcheck shell=bash

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Oh my zsh
source "$HOME/.config/zsh/oh-my-zsh.conf"

source "$HOME/.config/zsh/integrations.conf"

source "$HOME/.config/shell/history.conf"
source "$HOME/.config/shell/aliases.conf"
source "$HOME/.config/shell/functions.conf"
source "$HOME/.config/shell/exports.conf"
source "$HOME/.config/shell/completions/flux.conf"
if [[ -f "$HOME/.config/shell/secrets.conf" ]]; then
  source "$HOME/.config/shell/secrets.conf"
fi

# Auto create tmux session
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux_rbn || tmux new-session -s ssh_tmux_rbn
fi

# Auto complete for terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
