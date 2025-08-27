#!/usr/bin/env bash

BW() {
    sudo -u ${USERNAME} \
    BW_CLIENTID="${BW_CLIENTID}" BW_CLIENTSECRET="${BW_CLIENTSECRET}" \
    BW_PASSWORD="${BW_PASSWORD}" BW_SESSION=${BW_SESSION} BITWARDENCLI_APPDATA_DIR="${BITWARDENCLI_APPDATA_DIR}" \
    bw $@ 2>/dev/null
}

bitwarden_is_authenticated() {
    status=$(BW status |jq -r ".status" 2>/dev/null)
    if [ -z "${status}" ]; then
        false
    else 
        [[ ! ${status} == "unauthenticated" ]]
    fi
}
bitwarden_is_locked() {
    status=$(BW status 2>/dev/null |jq -r ".status" 2>/dev/null)
    if [ -z "${status}" ]; then
        true
    else
        [[ ${status} == "locked" ]] || ! bitwarden_is_authenticated
    fi
}

