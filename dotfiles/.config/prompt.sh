#!/usr/bin/env bash

source /etc/os-release

parse_git_branch()
{
	branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ <\1>/')
	if [ "$branch" = "" ]; then
	    echo ""
	else
	    echo -e " \Ue702$branch"
	fi
}

parse_docker_context()
{
	psdock=$(docker context inspect | jq --raw-output .[0].Name)
	if [ "$psdock" = "default" ]; then
		echo ""
	else
		echo -e " \Uf21f  $psdock"
	fi
}

parse_kubernetes_context()
{
	ctx=$(kubectx -c 2>/dev/null)
	if [ $? -ne 0 ]; then
		echo ""
		return
	fi

	if [ "$ctx" = "default" ]; then
		echo ""
	else
		echo -e " \Ue81d $ctx"
	fi
}

kernel_live_version() {
	echo $(uname -r)
}
kernel_installed_version() {
	pacout=$(pacman -Q linux-zen)
	pacarr=($pacout)
	echo "${pacarr[1]}-zen" | sed 's/\(.*\)\./\1-/'
}

PROMPT_NEED_REBOOT() {
	# Ignore that part of the prompt on non-arch distribution
	if ! [ "${ID}" = "arch" ]; then
		echo ""
		return
	fi

	live=$(kernel_live_version)
	installed=$(kernel_installed_version)
	if [ "$live" = "$installed" ]; then
	    echo ""
	else
	    echo -e '\[\e[38;2;252;23;3m\] \Uf0709 \[$(tput sgr0)\]'
	fi
}

PROMPT_GIT() {
	echo "\[$(tput setaf 142)\]\$(parse_git_branch)\[$(tput sgr0)\]"
}

PROMPT_DOCKER() {
	echo "\[\e[38;2;29;99;237m\]\$(parse_docker_context)\[$(tput sgr0)\]"
}

PROMPT_KUBE() {
	echo "\[\e[38;2;50;108;229m\]\$(parse_kubernetes_context)\[$(tput sgr0)\]"
}

PS1="[\[$(tput setaf 39)\]\u@\h\[$(tput sgr0)\]\[$(tput setaf 31)\] \W\[$(tput sgr0)\]$(PROMPT_GIT)$(PROMPT_DOCKER)$(PROMPT_KUBE)$(PROMPT_NEED_REBOOT)]\\$ \[$(tput sgr0)\]"
