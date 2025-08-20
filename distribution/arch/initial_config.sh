#!/usr/bin/env bash

configure_pacman() {
	# Configure pacman for color, multiple downloads
	sed -i 's/#Color/Color/' /etc/pacman.conf
	if [ $? -ne 0 ]; then
		echo -e "${BRed}Failed to edit /etc/pacman.conf (to enable color). Skipping.${NC}"
	fi
	sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
	if [ $? -ne 0 ]; then
		echo -e "${BRed}Failed to edit /etc/pacman.conf (to enable parallel downloads). Skipping.${NC}"
	fi
}

create_user() {
	# Create user (if needed)
	if ! id "${USERNAME}" >/dev/null 2>&1; then
		# Add user and set password
		useradd -m -c ${USER_COMMENT} -G root,wheel,i2c,input ${USERNAME}
		if [ $? -ne 0 ]; then
			echo -e "${BRed}Failed to add user ${USERNAME}${NC}. Skipping."
		fi
		echo "${USERNAME}:${PASSWORD}" | chpasswd
		if [ $? -ne 0 ]; then
			echo -e "${BRed}Failed to change user ${USERNAME} password${NC}. Skipping."
		fi
	else
		echo -e "${BNC}User '${USERNAME}' already exists, skipping user creation${NC}"
	fi
}


# Given that on Arch we don't have a dbus session yet, we need to launch one to apply dbus settings
DBUS_LAUNCH="sudo -u ${USERNAME} dbus-launch"

WHEEL_GROUP="wheel"

configure_pacman
create_user
