# Oxide theme for Zsh
#
# Author: Diki Ananta <diki1aap@gmail.com>
# Repository: https://github.com/dikiaap/dotfiles
# License: MIT

# Prompt:
# %F => Color codes
# %f => Reset color
# %~ => Current path
# %(x.true.false) => Specifies a ternary expression
#   ! => True if the shell is running with root privileges
#   ? => True if the exit status of the last command was success
#
# Git:
# %a => Current action (rebase/merge)
# %b => Current branch
# %c => Staged changes
# %u => Unstaged changes
#
# Terminal:
# \n => Newline/Line Feed (LF)

setopt PROMPT_SUBST

autoload -U add-zsh-hook
autoload -Uz vcs_info

# Use True color (24-bit) if available.
if [[ "${terminfo[colors]}" -ge 256 ]]; then
    oxide_turquoise="%F{73}"
    oxide_blue="%F{12}"
    oxide_orange="%F{179}"
    oxide_red="%F{167}"
    oxide_limegreen="%F{107}"
else
    oxide_turquoise="%F{cyan}"
    oxide_blue="%F{blue}"
    oxide_orange="%F{yellow}"
    oxide_red="%F{red}"
    oxide_limegreen="%F{green}"
fi

# Reset color.
oxide_reset_color="%f"

# VCS style formats.
FMT_UNSTAGED="%{$oxide_reset_color%} %{$oxide_orange%}●"
FMT_STAGED="%{$oxide_reset_color%} %{$oxide_limegreen%}✚"
FMT_ACTION="(%{$oxide_limegreen%}%a%{$oxide_reset_color%})"
FMT_VCS_STATUS="on %{$oxide_turquoise%} %b%u%c%{$oxide_reset_color%}"

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr    "${FMT_UNSTAGED}"
zstyle ':vcs_info:*' stagedstr      "${FMT_STAGED}"
zstyle ':vcs_info:*' actionformats  "${FMT_VCS_STATUS} ${FMT_ACTION}"
zstyle ':vcs_info:*' formats        "${FMT_VCS_STATUS}"
zstyle ':vcs_info:*' nvcsformats    ""
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# Check for untracked files.
+vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
            git status --porcelain | grep --max-count=1 '^??' &> /dev/null; then
        hook_com[staged]+="%{$oxide_reset_color%} %{$oxide_red%}●"
    fi
}

# Executed before each prompt.
add-zsh-hook precmd vcs_info

_user_info() {
    echo "%(!.%{$oxide_red%}%n%{$oxide_reset_color%}.%{$oxide_turquoise%}%n%{$oxide_reset_color%}) "
}

_host_info() {
    prefix="on"
    if [ $(print -P "%y" | cut -c-3) = "pts" ]; then
        echo "$prefix %m "
    fi
}

# Gather kube infos
_kube_info() {
    prefix="at"

    if [[ ! -f "$HOME/.config/.kubeprompt" || $(head -n 1 "$HOME/.config/.kubeprompt") == 'off' ]]; then
        return 0
    fi

    if command -v kubectx &> /dev/null && command -v kubens &> /dev/null; then
        kube_current_context=$(kubectx -c)
        [[ $kube_current_context == *"prod"* ]] && kube_current_context_color="$oxide_red" || kube_current_context_color="$oxide_blue"
        kube_current_context_format="%{$kube_current_context_color%}$kube_current_context%{$oxide_reset_color%}"

        kube_current_namespace=$(kubens -c)
        kube_current_namespace_format="%{$oxide_blue%}$kube_current_namespace%{$oxide_reset_color%}"

        echo "$prefix %{$kube_current_context_format%}:%{$kube_current_namespace_format%} "
    fi
}

set_kube_prompt_on() {
    echo "on" > "$HOME/.config/.kubeprompt"
}
set_kube_prompt_off() {
    echo "off" > "$HOME/.config/.kubeprompt"
}

_directory_info() {
    prefix="in"
    echo "$prefix %{$oxide_limegreen%}%(5~|../%3~|%~)%{$oxide_reset_color%} "
}

# Oxide prompt style.
PROMPT=$'\n%{$(_user_info)%}%{$(_host_info)%}%{$(_kube_info)%}%{$(_directory_info)%}${vcs_info_msg_0_}\n%(?.%{%F{white}%}.%{$oxide_red%})>%{$oxide_reset_color%} '
