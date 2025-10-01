# mymachine
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# OS-specific information
source /etc/os-release

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
if [ "${ID}" = "ubuntu" ]; then
    # On Ubuntu, Bitwarden snap is used, which changes the sock path
    export SSH_AUTH_SOCK=/home/${USER}/snap/bitwarden/current/.bitwarden-ssh-agent.sock
else
    export SSH_AUTH_SOCK=/home/${USER}/.bitwarden-ssh-agent.sock
fi

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
if [ "${ID}" = "ubuntu" ]; then
    alias apt="sudo nala"
fi

### End of default bashrc, append anything here
