#!/usr/bin/env bash

WHEEL_GROUP="sudo"

# Enable docker IPv4 forwarding, to allow LXD to work along it :)
echo "net.ipv4.conf.all.forwarding=1" > /etc/sysctl.d/99-forwarding.conf
sysctl net.ipv4.conf.all.forwarding=1 >/dev/null 2>&1

export BITWARDENCLI_APPDATA_DIR="/home/${USERNAME}/snap/bw/current/Bitwarden CLI"
