#!/usr/bin/env bash

alias bw="sudo -u ${USERNAME} bw"

bitwarden_is_authenticated() {
    status=$(bw status |jq -r ".status")
    [[ ! ${status} == "unauthenticated" ]]
}
bitwarden_is_locked() {
    status=$(bw status |jq -r ".status")
    [[ ${status} == "locked" ]] || ! bitwarden_is_authenticated
}

