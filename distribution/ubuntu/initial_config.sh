#!/usr/bin/env bash

disable_unwanted_extensions() {
    # Disable default Ubuntu gnome extensions
    sudo -u ${USERNAME} gnome-extensions disable ding@rastersoft.com # Desktop Icons
}

WHEEL_GROUP="sudo"

disable_unwanted_extensions

# Enable docker IPv4 forwarding, to allow LXD to work along it :)
echo "net.ipv4.conf.all.forwarding=1" > /etc/sysctl.d/99-forwarding.conf
sysctl net.ipv4.conf.all.forwarding=1 >/dev/null 2>&1
