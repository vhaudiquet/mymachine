#!/usr/bin/env bash

disable_unwanted_extensions() {
    # Disable default Ubuntu gnome extensions
    gnome-extensions disable ding@rastersoft.com # Desktop Icons
}

WHEEL_GROUP="sudo"

disable_unwanted_extensions
