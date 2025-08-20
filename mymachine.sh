#!/usr/bin/env bash

if [ -z "${USERNAME}" ]; then
	USERNAME=${USER}
fi
EMAIL=${EMAIL}
USER_COMMENT=${USER_COMMENT}
USER_PICTURE_URL=${USER_PICTURE_URL}
PASSWORD=${PASSWORD}

YCMD="yes O"
KEYMAP=fr

DBUS_LAUNCH="sudo -u ${USERNAME}"
MICROCODE_INSTALLED=true

current_dir=$(pwd)
script_dir=$(dirname -- $(readlink -f $0))
script_name=$(basename $0)

# Check if stdout is tty before outputting color
if [ -t 1 ]; then
    BGreen='\033[1;32m'
    BRed='\033[1;31m'
    BYellow='\033[1;33m'
    BNC='\033[1m'
    NC='\033[0m'
else
    BGreen=''
    BRed=''
    BYellow=''
    BNC=''
    NC=''
fi

# Trap SIGINT
trap handle_int INT
handle_int() {
    echo -e "\n${BYellow}SIGINT captured, terminated.${NC}"
    exit 1
}

# Ask the user to input PASSWORD if not set
if [ -z "${USERNAME}" ] || [ ${USERNAME} = "root" ]; then
    read -p "Username: " USERNAME
fi
if [[ -z ${GIT_USER} ]]; then
	GIT_USER=$(git config --global user.name)
	if [ -z ${GIT_USER} ]; then
    	GIT_USER=${USERNAME}
	fi
fi
# Ask for user comment and password if user does not yet exist
if ! id "${USERNAME}" >/dev/null 2>&1; then
	if [ -z "${USER_COMMENT}" ]; then
		read -p "Full name: " USER_COMMENT
	fi
	if [ -z "${PASSWORD}" ]; then
		read -s -p "Password: " PASSWORD
	fi
	echo ""
fi
if [ -z "${EMAIL}" ]; then
	EMAIL=$(git config --global user.email)
	if [ -z "${EMAIL}" ]; then
		read -p "Email: " EMAIL
	fi
fi
if [ -z "${USER_PICTURE_URL}" ] && [ ! -f "/var/lib/AccountsService/icons/${USERNAME}" ]; then
	read -p "User profile picture URL (leave blank for none): " USER_PICTURE_URL
fi

# Make sure we are running as root
if [[ $EUID -ne 0 ]]; then
    # If we are not running as root, try to relaunch ourselves as root
    echo -e "${BNC}Testing root access...${NC}"
    sudo bash -c "USERNAME=${USERNAME} GIT_USER=${GIT_USER} EMAIL=${EMAIL} USER_COMMENT=${USER_COMMENT} USER_PICTURE_URL=${USER_PICTURE_URL} PASSWORD=${PASSWORD} ${script_dir}/${script_name}"
	exit $?
else
	echo -e "${BNC}Root access obtained.${NC}"
fi

# Detect distribution
source /etc/os-release
if ! [[ -d ${current_dir}/distribution/${ID} ]]; then
    echo -e "${BRed}Error: distribution ${ID} not supported. Terminating.${NC}"
    return 1 2>/dev/null || exit 1
fi

echo -e "${BNC}Detected distribution ${NAME} (${ID})${NC}"

# Initial configuration step
source ${script_dir}/distribution/${ID}/initial_config.sh

# Change directory to user home
cd /home/${USERNAME}/

# Authorize members of group ${WHEEL_GROUP} to sudo, without password (if needed)
if ! [[ "$(tail -n 1 /etc/sudoers)" = "%${WHEEL_GROUP} ALL=(ALL:ALL) NOPASSWD: ALL" ]]; then
	echo "%${WHEEL_GROUP} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
	if [ $? -ne 0 ]; then
		echo -e "${BRed}Failed to edit /etc/sudoers. Terminating.${NC}"
		exit 1
	fi
fi

# Install packages
source ${script_dir}/distribution/${ID}/install.sh
install_package() {
	package="${1}"
	command="${2}"
	
	# Print current package on terminal
	echo -ne "${package}"

	${command} "${package}"
	if [ $? -ne 0 ]; then
		echo -e "\n${BRed}Failed to install package '${package}'. Skipping."
	fi

	# Remove current package name from terminal
	count=$(echo "${package}" | wc -m)
	for ((i=1; i<$count; i++)); do echo -ne '\b'; done
	for ((i=1; i<$count; i++)); do echo -ne ' '; done
	for ((i=1; i<$count; i++)); do echo -ne '\b'; done
}

refresh_package_db
if [ $? -ne 0 ]; then
	echo -e "${BRed}Could not refresh package database. Terminating."
	return 1 2>/dev/null || exit 1
fi

echo -ne "Installing packages...  "
for package in "${PACKAGES[@]}"; do
	install_package "${package}" install_package_command
done
echo ""

# Install distribution-specific extra packages
echo -e "Initializing extra package installation..."
extra_init
echo -ne "${EXTRA_INSTALL_MESSAGE}...  "
for package in "${EXTRA_PACKAGES[@]}"; do
	install_package "${package}" install_extra_command
done
echo ""
extra_finish

# GNOME SETTINGS, EXTENSIONS, ...
source "${script_dir}/gnome.sh"

# Create gnome/gdm user info file
if ! [ -z "${USER_PICTURE_URL}" ]; then
	echo "Downloading user profile picture..."
    curl -L -o "/var/lib/AccountsService/icons/${USERNAME}" "${USER_PICTURE_URL}"
    echo -e "[User]\nSession=\nIcon=/var/lib/AccountsService/icons/${USERNAME}\nSystemAccount=false\n" > /var/lib/AccountsService/users/${USERNAME}
fi

# Install VSCode extensions
export VSCODE_EXTENSIONS="${script_dir}/vscode-extensions.txt"
echo -ne "Installing VSCode extensions...      "
i=0 total=$(wc -l < ${VSCODE_EXTENSIONS}); while read ext; do
  # TODO: Here we assume extensions are at most a 2-digit number ; change that :)
  istr=$(printf "%02d" $i)
  echo -ne "\b\b\b\b\b${istr}/${total}"
  sudo -u ${USERNAME} code --install-extension "${ext}" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
	echo -e "\n${BRed}Error when installing VSCode extensions. Failing extension: '${ext}'${NC}\nSkipping next extensions, manual intervention required."
	break
  fi
  i=$((i + 1))
done <"${VSCODE_EXTENSIONS}";
if [[ $i = $total ]]; then
	echo -ne "\b\b\b\b\b${total}/${total}"
	echo ""
fi

# Install dotfiles, without overwriting
echo "Installing dotfiles..."
cp -r --update=none ${script_dir}/dotfiles/. /home/${USERNAME}/
cat ${script_dir}/dotfiles/.config/git/config | envsubst '$GIT_USER $EMAIL' >/home/${USERNAME}/.config/git/config

# TODO: Setup GRUB theme
echo "Setting up GRUB theme..."
# $YCMD | pacman -S grub-theme-vimix
# sed -i 's/#GRUB_THEME=\"\/path\/to\/gfxtheme\"/GRUB_THEME=\"\/usr\/share\/grub\/themes\/Vimix\/theme.txt\"/' /etc/default/grub
# if [ $? -ne 0 ]; then
# 	echo "Failed to edit /etc/default/grub (to enable grub theme)"
# 	return 1 2>/dev/null || exit 1
# fi
grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>/dev/null

# VPN configuration
echo "Setting up VPN..."
# sudo -u ${USERNAME} mkdir /home/${USERNAME}/.wireguard
# sudo -u ${USERNAME} wg genkey > /home/${USERNAME}/.wireguard/privatekey
# TODO: Add networkmanager wireguard connection

# Print last setup needed message
echo -e "${BNC}MyMachine is done${NC}"
if [[ "${ID}" = "arch" ]]; then
	echo "Now you need to check if GDM works, and enable it if so (or install graphics drivers if not)"
	echo "You also need to install video decode hwaccel drivers (libva, ...)"
fi
if [ "$MICROCODE_INSTALLED" == "false" ]; then
	echo "We could not detect your processor brand (${CPU_VENDOR}) ; you may need to install microcode manually"
	if [[ "${ID}" = "arch" ]]; then
		echo "Packages: pacman -S amd-ucode/intel-ucode, then regenerate grub config"
	fi
fi
echo "To use WireGuard, don't forget to add this client on VPN server (your private key is under ~/.wireguard/privatekey)"
echo "To use GitHub, you need to use 'gh auth login' to connect to GitHub"
echo -e "${BNC}Goodbye ! Make sure to ${BGreen}reboot${BNC} to apply all changes !${NC}"
