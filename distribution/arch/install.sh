#!/usr/bin/env bash

PACKAGES=(
	i2c-tools # Needed for group i2c
	sudo
	wget
	curl
	jq
	micro
	wl-clipboard
	networkmanager
	# Gnome
	baobab
	papers
	file-roller
	gdm
	gnome-backgrounds
	gnome-calculator
	gnome-color-manager
	gnome-control-center
	gnome-disk-utility
	gnome-font-viewer
	gnome-keyring
	gnome-logs
	gnome-menus
	gnome-session
	gnome-settings-daemon
	gnome-shell
	gnome-shell-extensions
	gnome-system-monitor
	gnome-text-editor
	gvfs
	gvfs-afc
	gvfs-goa
	gvfs-google
	gvfs-gphoto2
	gvfs-mtp
	gvfs-smb
	nautilus
	sushi
	xdg-user-dirs-gtk
	eog
	gnome-tweaks
	gnome-themes-extra
	webp-pixbuf-loader
	gnome-text-editor
	power-profiles-daemon
	xdg-desktop-portal
	xdg-desktop-portal-gtk
	xdg-desktop-portal-gnome
	# End of gnome
	ddcutil # Needed for brightness control
	# Ghostty
	ghostty
	ghostty-terminfo
	ghostty-shell-integration
	# Git-needed secret stores
	libsecret
	gnome-keyring
	# Secret store GUI
	seahorse
	# Audio
	pipewire
	pipewire-alsa
	pipewire-audio
	pipewire-pulse
	pipewire-jack
	wireplumber
	# Git, and needed software to build software
	git
	base-devel
	# Fonts
	ttf-fira-code
	ttf-inconsolata
	ttf-liberation
	ttf-roboto
	ttf-dejavu
	cantarell-fonts
	adobe-source-code-pro-fonts
	ttf-droid
	noto-fonts
	gnu-free-fonts
	# Mail client
	geary
	# Photo/Graphics utils
	inkscape
	gimp
	darktable
	# LaTeX
	texlive-bin
	texlive-binextra
	texlive-basic
	texlive-mathscience
	texlive-latexextra
	texlive-publishers
	texlive-formatsextra
	texlive-bibtexextra
	# Shell completion
	bash-completion
	# Man pages
	man-db
	man-pages
	# NFS
	nfs-utils
	gvfs-nfs
	# Github CLI
	github-cli
	# Code, and needed packages
	code
	clang
	# Communication tools
	discord
	fractal
	polari
	# Video utils
	mpv
	vlc
	# Printing
	cups cups-pk-helper cups-filters libcups
	# MDNS
	avahi
	# Firmware
	gnome-firmware
	fwupd
	# Wireguard usermode utils
	wireguard-tools
	# QEMU
	qemu-base
	qemu-desktop
	qemu-tools
	qemu-img
	qemu-user
	qemu-ui-gtk
	qemu-ui-sdl
	qemu-ui-dbus
	qemu-audio-pa
	qemu-common
	qemu-ui-opengl
	qemu-block-ssh
	qemu-audio-sdl
	qemu-block-dmg
	qemu-block-nfs
	qemu-audio-oss
	qemu-ui-curses
	qemu-audio-jack
	qemu-audio-alsa
	qemu-block-curl
	qemu-audio-dbus
	qemu-pr-helper
	qemu-hw-usb-host
	qemu-system-x86
	qemu-system-arm
	qemu-audio-spice
	qemu-system-mips
	qemu-ui-spice-app
	qemu-system-riscv
	qemu-ui-spice-core
	qemu-chardev-spice
	qemu-hw-display-qxl
	qemu-hw-usb-redirect
	qemu-system-aarch64
	qemu-ui-egl-headless
	qemu-vhost-user-gpu
	qemu-hw-usb-smartcard
	qemu-hw-display-virtio-vga
	qemu-hw-display-virtio-gpu
	qemu-hw-display-virtio-gpu-gl
	qemu-hw-display-virtio-vga-gl
	qemu-hw-s390x-virtio-gpu-ccw
	qemu-hw-display-virtio-gpu-pci
	qemu-system-arm-firmware
	qemu-system-x86-firmware
	qemu-hw-display-virtio-gpu-pci-gl
	qemu-system-riscv-firmware
	vde2
	# Bitwarden, password manager
	bitwarden
	bitwarden-cli
	# Docker/Kube
	docker
	kubectl
	kubectx
	docker-compose
	# Others
	pre-commit
	sops
	chromium
	obs-studio
)

EXTRA_PACKAGES=(
	code-features
	code-marketplace
	wasistlos
	revolt-desktop-bin
	jellyfin-media-player
	zen-browser-bin
	spotify
)

install_package_command() {
	$YCMD | pacman -S --needed "${1}" >/dev/null 2>&1
}

install_extra_command() {
	$YCMD | sudo -u ${USERNAME} yay -S --needed "${1}" >/dev/null 2>&1
}

refresh_package_db() {
	# Refresh pacman db
	echo -e "Refreshing pacman database..."
	$YCMD | pacman -Sy >/dev/null 2>&1
}

install_yay() {
	# Install yay (if not present)
	yay=$(which yay 2>/dev/null)
	if [ $? -ne 0 ]; then
		echo -e "Installing yay..."
		sudo -u ${USERNAME} git clone https://aur.archlinux.org/yay.git
		if [ $? -ne 0 ]; then
			echo "Failed to git clone yay"
			return 1 2>/dev/null || exit 1
		fi
		cd yay
		$YCMD | sudo -u ${USERNAME} makepkg -si
		if [ $? -ne 0 ]; then
			echo "Failed to makepkg si"
			return 1 2>/dev/null || exit 1
		fi
		yay -Y --gendb
		if [ $? -ne 0 ]; then
			echo "Failed to yay --gendb"
			return 1 2>/dev/null || exit 1
		fi
		cd ..
		rm -rf yay
	else
		echo -e "${BNC}Skipping yay installation, already present${NC}"
	fi
}

install_microcode() {
	# Detect wether CPU is AMD or Intel, for microcode installation
	CPU_VENDOR=$(cat /proc/cpuinfo | grep vendor | uniq | awk '{print $3}')
	if [ "$CPU_VENDOR" == "AuthenticAMD" ]; then
		# Install AMD microcode
		$YCMD | pacman -S --needed amd-ucode >/dev/null 2>&1
	elif [ "$CPU_VENDOR" == "GenuineIntel" ]; then
		# Install Intel microcode
		$YCMD | pacman -S --needed intel-ucode >/dev/null 2>&1
	else
		echo "Unknown CPU vendor : ${CPU_VENDOR} ; skipping microcode install"
		MICROCODE_INSTALLED=false
	fi
}

export EXTRA_INSTALL_MESSAGE="Installing AUR packages with yay"

extra_init() {
	install_microcode
	install_yay

	# Configure keymap
    echo "KEYMAP=${KEYMAP}" >/etc/vconsole.conf
    ${DBUS_LAUNCH} dconf write /org/gnome/desktop/input-sources/sources "[('xkb', '${KEYMAP}')]"
    localectl set-x11-keymap ${KEYMAP}
}

extra_finish() {
	# Enable installed services
	systemctl enable cups
	systemctl enable avahi-daemon
}
