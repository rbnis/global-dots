# shellcheck shell=bash

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:/usr/local/bin:$PATH"

source "$HOME/.config/shell/history.conf"
source "$HOME/.config/shell/aliases.conf"
source "$HOME/.config/shell/exports.conf"
if [[ -f "$HOME/.config/shell/secrets.conf" ]]; then
source "$HOME/.config/shell/secrets.conf"
fi

if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux_rbn || tmux new-session -s ssh_tmux_rbn
fi
