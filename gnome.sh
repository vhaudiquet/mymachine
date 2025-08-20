#!/usr/bin/env bash

configure_gnome_settings() {
    # Configure mouse settings : flat
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/peripherals/mouse/accel-profile "'flat'"
    # Configure touchpad settings : emulate left/right click areas
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/peripherals/touchpad/click-method "'areas'"
    # Show battery percentage
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/interface/show-battery-percentage true
    # Disable 'hot' corners
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/interface/enable-hot-corners false
    # Show all 3 min/max/close buttons on windows
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'"
    # Set alt-tab to current workspace only
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/app-switcher/current-workspace-only true


    # Configure gnome to use dark theme
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"

    # Set 'favorite' apps
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/favorite-apps \
    "['org.gnome.Nautilus.desktop', \
    'com.mitchellh.ghostty.desktop', \
    'zen.desktop', \
    'code-oss.desktop', \
    'org.kicad.kicad.desktop', \
    'android-studio.desktop', \
    'discord.desktop', 'discord_discord.desktop', \
    'org.gnome.Calculator.desktop', \
    'org.gnome.TextEditor.desktop', \
    'org.gnome.Geary.desktop', \
    'lunacy.desktop', \
    'notesnook.desktop', \
    'org.gnome.Papers.desktop', \
    'org.gnome.Settings.desktop', \
    'com.github.xeco23.WasIstLos.desktop', 'wasistlos_wasistlos.desktop', \
    'spotify.desktop', 'spotify_spotify.desktop', \
    'bitwarden.desktop', 'bitwarden_bitwarden.desktop',\
    'OrcaSlicer.desktop']"
}

configure_dash2dock_settings() {
    # Set dash-to-dock parameters
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/always-center-icons true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/animate-show-apps false
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/apply-custom-theme false
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/background-color "'rgb(36,31,49)'"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity "'0,8'"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/custom-background-color false
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size "30"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/disable-overview-on-startup true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/height-fraction 1
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/isolate-workspaces true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/multi-monitor true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/running-indicator-style "'DASHES'"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts false
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts-network false
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/show-show-apps-button true
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash false
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/dash-to-dock/transparency-mode "'FIXED'"
}

configure_wallpapers_settings() {
    if ! [ -d "/home/${USERNAME}/Images/Wallpapers" ]; then 
        git clone --depth 1 https://github.com/vhaudiquet/wallpapers "/home/${USERNAME}/Images/Wallpapers"
    fi

    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/azwallpapers/slideshow-directory "'/home/${USERNAME}/Images/Wallpapers'"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/azwallpapers/slideshow-queue-sort-type "'A-Z'"
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/azwallpapers/slideshow-slide-duration "(1, 0, 0)"
}

configure_misc_settings() {
    # Brightness control using ddcutil
    ${DBUS_LAUNCH} dconf write /org/gnome/shell/extensions/display-brightness-ddcutil/button-location 1
}

enable_extension_uuid() {
    sudo -u ${USERNAME} gnome-extensions enable "$1" >/dev/null 2>&1
}
install_extension_from_file() {
    sudo -u ${USERNAME} gnome-extensions install "$1" -f >/dev/null 2>&1
}
parse_extension_id_from_link() {
    url="$(echo "$1" | sed '/^[[:space:]]*$/d')"
    ext_id="$(echo "$url" | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | awk '{print $1;}')"
    echo "${ext_id}"
}

# Inspired from:
# github.com:ToasterUwU/install-gnome-extensions
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)"
install_extension() {
	link="${1}"
	ext_id=$(parse_extension_id_from_link "${link}")
	request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$GNOME_SHELL_VERSION"

	http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")"
	if [ "$http_response" = 404 ]; then
        echo -e "${BRed}Gnome extension ${ext_id} not found for shell version ${GNOME_SHELL_VERSION}. Skipping.${NC}"
        return
	fi

	ext_info="$(curl -s "$request_url")"
	ext_uuid="$(echo "$ext_info" | jq -r '.uuid')"
	direct_dload_url="$(echo "$ext_info" | jq -r '.download_url')"
	download_url="https://extensions.gnome.org"$direct_dload_url
	
	filename="$(basename "$download_url")"
    wget -q "$download_url"
    install_extension_from_file "$filename"
    if [ $? -ne 0 ]; then
        echo -e "${BRed}Could not install gnome extension ${ext_id}. Skipping.${NC}"
        rm -f ${filename}
        return
    fi

    # Cleanup downloaded extension file
    rm -f "$filename"

	enable_extension_uuid "$ext_uuid"
    if [ $? -ne 0 ]; then
        echo -e "${BRed}Could not enable gnome extension ${ext_id}. Skipping.${NC}"
    fi
}

install_extensions_from_links_file() {
    i=0 total=$(wc -l < ${1}) totalstr=$(printf "%02d" $total); while read ext; do
        # TODO: Here we assume extensions are at most a 2-digit number ; change that :)
        istr=$(printf "%02d" $i)
        echo -ne "\b\b\b\b\b${istr}/${totalstr}"
        
        install_extension "${ext}"

        i=$((i + 1))
    done <"${1}";
    if [[ $i = $total ]]; then
        echo -ne "\b\b\b\b\b${totalstr}/${totalstr}"
        echo ""
    fi
}

# Install gnome extensions
echo -ne "Installing Gnome extensions...       "

# Enable gnome user extensions
${DBUS_LAUNCH} dconf write /org/gnome/shell/disable-user-extensions false
if [ $? -ne 0 ]; then
	echo -e "${BRed}Failed to (${DBUS_LAUNCH}) dconf to enable Gnome user extensions. Terminating.${NC}"
	exit 1
fi

install_extensions_from_links_file "${script_dir}/gnome-extensions.txt"

# Install distribution-specific extensions if needed
if [[ -f ${script_dir}/distribution/${ID}/gnome-extensions.txt ]]; then
    echo -ne "Installing distribution-specific Gnome extensions...       "
    install_extensions_from_links_file "${script_dir}/distribution/${ID}/gnome-extensions.txt"
fi

# Enable needed default extensions
${DBUS_LAUNCH} gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
${DBUS_LAUNCH} gnome-extensions enable system-monitor@gnome-shell-extensions.gcampax.github.com

echo "Setting up Gnome settings..."

configure_gnome_settings
configure_dash2dock_settings
configure_wallpapers_settings
