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

bitwarden_login() {
    # Login to Bitwarden
    if ! bitwarden_is_authenticated; then
        if [ ! -z "${BW_CLIENTID}" ] && [ ! -z "${BW_CLIENTSECRET}" ]; then
            echo "Login in to Bitwarden..."
            BW_CLIENTID="${BW_CLIENTID}" BW_CLIENTSECRET="${BW_CLIENTSECRET}" BW login --apikey >/dev/null
            if [ $? -ne 0 ]; then
                echo -e "${BRed}Could not login to Bitwarden. Skipping.${NC}"
            fi
        else
            echo "Skipping Bitwarden authentication, no credentials provided."
        fi
    fi
    if bitwarden_is_authenticated && bitwarden_is_locked; then
        if [ ! -z "${BW_PASSWORD}" ]; then
            echo "Unlocking Bitwarden vault..."
            export BW_SESSION=$(BW unlock --raw ${BW_PASSWORD})
            if [ -z "${BW_SESSION}" ]; then
                echo -e "${BRed}Could not unlock Bitwarden vault. Skipping.${NC}"
            fi
        fi
    fi
}
