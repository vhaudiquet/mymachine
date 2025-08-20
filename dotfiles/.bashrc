#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History file settings
# No duplicate lines / lines starting with space in history
HISTCONTROL=ignoreboth
# Append to history file (no overwrite)
shopt -s histappend
# File and history sizes
HISTSIZE=1000
HISTFILESIZE=2000

# Check window size after each command, and update accordingly
shopt -s checkwinsize

# Enable color in classic programs
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias dir='dir --color=auto'
export MICRO_TRUECOLORS=1

# Bash completion
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
fi

# Prompt
source /home/${USER}/.config/prompt.sh

# Bitwarden SSH agent
export SSH_AUTH_SOCK=/home/${USER}/.bitwarden-ssh-agent.sock

# PATH modifications
# Local binaries
export PATH="${PATH}:/home/${USER}/.local/bin"

# Editor
export EDITOR=micro

# Aliases
alias e=${EDITOR}
alias l="ls -lla"
alias c="clear"
alias k="kubectl"
