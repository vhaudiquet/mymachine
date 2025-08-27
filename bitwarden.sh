#!/usr/bin/env bash

alias bw="sudo -u ${USERNAME} bw"

bitwarden_is_authenticated() {
    status=$(bw status 2>/dev/null |jq -r ".status" 2>/dev/null)
    if [ -z "${status}" ]; then
        false
    else 
        [[ ! ${status} == "unauthenticated" ]]
    fi
}
bitwarden_is_locked() {
    status=$(bw status 2>/dev/null |jq -r ".status" 2>/dev/null)
    if [ -z "${status}" ]; then
        true
    else
        [[ ${status} == "locked" ]] || ! bitwarden_is_authenticated
    fi
}

